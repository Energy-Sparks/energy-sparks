module Amr
  class N3rgyReadingsDownloadAndUpsert
    def initialize(
        meter:,
        config:,
        override_start_date: nil,
        override_end_date: nil
      )
      @meter = meter
      @config = config
      @override_start_date = override_start_date
      @override_end_date = override_end_date
    end

    def perform
      # if n3rgy dont provide us with dates, we can't load data
      return if available_date_range.empty?

      # determine start/end dates for API request, allowing for
      # overrides and presence of previously loaded data
      start_date = determine_start_date
      end_date = determine_end_date

      import_log = create_import_log(start_date, end_date)
      readings = N3rgyDownloader.new(meter: @meter, start_date: start_date, end_date: end_date).readings
      N3rgyReadingsUpserter.new(meter: @meter, config: @config, readings: readings, import_log: import_log).perform
    rescue => e
      msg = "Error downloading data for #{@meter.mpan_mprn} from #{start_date} to #{end_date} : #{e.message}"
      import_log.update!(error_messages: msg) if import_log
      Rails.logger.error msg
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :n3rgy_download, meter_id: @meter.mpan_mprn, start_date: start_date, end_date: end_date)
    end

    private

    def available_date_range
      @available_date_range ||= Meters::N3rgyMeteringService.new(@meter).available_data
    end

    def create_import_log(start_date, end_date)
      AmrDataFeedImportLog.create(
        amr_data_feed_config_id: @config.id,
        file_name: "N3rgy API import for #{@meter.mpan_mprn} for #{start_date} - #{end_date}",
        import_time: DateTime.now.utc)
    end

    def current_date_range_of_readings
      if @meter.amr_data_feed_readings.any?
        first = @meter.amr_data_feed_readings.minimum(:reading_date)
        last = @meter.amr_data_feed_readings.maximum(:reading_date)
        (n3rgy_first_reading_of_day(DateTime.parse(first + 'T00:30'))..
          n3rgy_last_reading_of_day(DateTime.parse(last + 'T00:00')))
      end
    end

    def determine_start_date
      return @override_start_date if @override_start_date
      return nil if available_date_range.empty?

      start = available_date_range.first

      # start new loading from end of existing readings if we have any
      current_range = current_date_range_of_readings
      if current_range && current_range.first <= start
        start = current_range.last
      end

      # ensure we're requesting the first reading of the day
      n3rgy_first_reading_of_day(start)
    end

    def determine_end_date
      return @override_end_date if @override_end_date
      return nil if available_date_range.empty?

      end_date = available_date_range.last

      # encountered a data problem at n3rgy where availableCacheRange had a future date
      end_date = DateTime.now if end_date >= Time.zone.today

      # force to midnight (last reading of previous day) to avoid loading partial data if
      # n3rgy have a few hours for today
      n3rgy_last_reading_of_day(end_date)
    end

    # n3rgy uses 00:30 as the first half-hourly reading for a day
    # so convert the date to a date time and set the time accordingly
    def n3rgy_first_reading_of_day(date_time)
      date_time.change(hour: 0, min: 30, sec: 0)
    end

    # the last half-hourly reading for a day in the n3rgy API is
    # midnight of the following day.
    #
    # so convert date to a date time and set time accordingly
    def n3rgy_last_reading_of_day(date_time)
      date_time.change(hour: 0, min: 0, sec: 0)
    end
  end
end
