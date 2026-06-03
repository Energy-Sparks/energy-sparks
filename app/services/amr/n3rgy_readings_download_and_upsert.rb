# frozen_string_literal: true

module Amr
  class N3rgyReadingsDownloadAndUpsert
    def initialize(
      meter:,
      config:,
      override_start_date: nil,
      override_end_date: nil,
      reload: false
    )
      @meter = meter
      @config = config
      @override_start_date = override_start_date
      @override_end_date = override_end_date
      @reload = reload
    end

    def perform
      # if n3rgy dont provide us with dates, we can't load data
      return 'no data available' if available_date_range.empty?

      # determine start/end dates for API request, allowing for
      # overrides and presence of previously loaded data
      start_date = determine_start_date
      end_date = determine_end_date

      # can happen if available end from n3rgy is only part way through the day and
      # we've then set end_date to be end of the previous day to avoid loading
      # incomplete readings.
      return 'start date after end date' if start_date > end_date

      import_log = create_import_log(start_date, end_date)
      readings = N3rgyDownloader.new(meter: @meter, start_date:, end_date:).readings
      N3rgyReadingsUpserter.new(meter: @meter, config: @config, readings:, import_log:).perform
      import_log
    rescue StandardError => e
      msg = "Error downloading data for #{@meter.mpan_mprn} from #{start_date} to #{end_date} : #{e.message}"
      import_log&.update!(error_messages: msg)
      Rails.logger.error msg
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :n3rgy_download, meter_id: @meter.mpan_mprn, start_date:, end_date:)
      msg
    end

    private

    def available_date_range
      @available_date_range ||= Meters::N3rgyMeteringService.new(@meter).available_data
    end

    def create_import_log(start_date, end_date)
      AmrDataFeedImportLog.create(
        amr_data_feed_config_id: @config.id,
        file_name: "N3rgy API import for #{@meter.mpan_mprn} for #{start_date} - #{end_date}",
        import_time: DateTime.now.utc,
        records_imported: 0
      )
    end

    def current_date_range_of_readings
      return unless existing_n3rgy_readings.any?

      first = DateTime.parse(existing_n3rgy_readings.minimum(:reading_date))
      # Instead of using the maximum date, we now use 7 days prior to that
      # so we're regularly refreshing the last 7 days of data.
      last = DateTime.parse(existing_n3rgy_readings.maximum(:reading_date)) - 7.days
      [n3rgy_first_reading_of_day(first), n3rgy_last_reading_of_day(last)]
    end

    def existing_n3rgy_readings
      @meter.amr_data_feed_readings.where(amr_data_feed_config: AmrDataFeedConfig.n3rgy_api.first)
    end

    # Example available cache dates from n3rgy
    #
    # 202305310030 data starts with the first reading of 2023-05-31. Request from here
    # 202305310330 data starts later in the day of 2024-05-31. Request from first reading
    # 202305310000 data starts with final reading of 2023-05-30. So wind back a full day
    def determine_start_date
      return @override_start_date if @override_start_date
      return nil if available_date_range.empty?

      start = available_date_range.first

      # if the n3rgy start date is midnight, then we should wind back a day
      start = n3rgy_first_reading_of_day(start - 1) if start == start.at_midnight

      # if set to reload, then just use dates from n3rgy
      return n3rgy_first_reading_of_day(start) if @reload

      # Continue loading newer readings if there's no additional historical data
      # in n3rgy.
      #
      # As the end of our current range includes reloading of last 7 days, then
      # also check that this isn't before the available date range
      # start new loading from the end of any existing readings if we have any
      current_range = current_date_range_of_readings
      start = current_range.last if current_range && current_range.first <= start && current_range.last > start

      # ensure we're requesting the first reading of the day
      n3rgy_first_reading_of_day(start)
    end

    def determine_end_date
      return @override_end_date if @override_end_date
      return nil if available_date_range.empty?

      end_date = available_date_range.last

      # encountered a data problem at n3rgy where availableCacheRange had a future date
      end_date = DateTime.now if end_date >= Time.zone.today

      # temporary n3rgy issue with other dcc meters where need to avoid last day of readings
      end_date -= 1.day if @meter.dcc_meter == 'other'

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
