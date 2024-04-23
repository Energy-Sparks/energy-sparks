module Amr
  class N3rgyReadingsDownloadAndUpsert
    def initialize(
        meter:,
        config:,
        start_date:,
        end_date:
      )
      @meter = meter
      @config = config
      @start_date = start_date
      @end_date = end_date
    end

    def perform
      unless @start_date && @end_date
        available_dates = fetch_cached_dates
        current_dates = readings_current_date_range(@meter)
      end

      start_date = @start_date || Amr::N3rgyDownloaderDates.start_date(available_dates, current_dates)
      end_date = @end_date || Amr::N3rgyDownloaderDates.end_date(available_dates)

      return if (start_date.strftime('Y%m%d') == end_date.strftime('%Y%m%d')) && (end_date.strftime('%H%M') != '2330')

      import_log = create_import_log
      readings = N3rgyDownloader.new(meter: @meter, start_date: start_date, end_date: end_date).readings
      N3rgyReadingsUpserter.new(meter: @meter, config: @config, readings: readings, import_log: import_log).perform
    rescue => e
      import_log.update!(error_messages: "Error downloading data from #{start_date} to #{end_date} : #{e.message}") if import_log
      Rails.logger.error "Exception: downloading N3rgy data for #{@meter.mpan_mprn} from #{start_date} to #{end_date} : #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :n3rgy_download, meter_id: @meter.mpan_mprn, start_date: start_date, end_date: end_date)
    end

    private

    def fetch_cached_dates
      Meters::N3rgyMeteringService.new(@meter).available_data
    end

    def create_import_log
      AmrDataFeedImportLog.create(
        amr_data_feed_config_id: @config.id,
        file_name: "N3rgy API import for #{@meter.mpan_mprn} #{DateTime.now.utc}",
        import_time: DateTime.now.utc)
    end

    def readings_current_date_range(meter)
      if meter.amr_data_feed_readings.any?
        first = meter.amr_data_feed_readings.minimum(:reading_date)
        last = meter.amr_data_feed_readings.maximum(:reading_date)
        # n3rgy uses 00:30 as the start of readings for a day, so parse the iso8601 string to
        # a date and set time
        #
        # for the end of the range we have to increment the date as n3rgy treats midnight of the
        # following day as the final reading of the previous day
        (to_date_with_specific_time(first, 0, 0, 30)..to_date_with_specific_time(last, 1, 0, 0))
      end
    end

    def to_date_with_specific_time(date, days, hour, min)
      (Date.parse(date) + days).to_time.change(hour: hour, min: min, sec: 0)
    end
  end
end
