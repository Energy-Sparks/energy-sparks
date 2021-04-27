module Amr
  class N3rgyReadingsDownloadAndUpsert
    def initialize(
        meter:,
        config:,
        start_date:,
        end_date:,
        n3rgy_api_factory: Amr::N3rgyApiFactory.new
      )
      @meter = meter
      @config = config
      @n3rgy_api_factory = n3rgy_api_factory
      @start_date = start_date
      @end_date = end_date
    end

    def perform
      unless @start_date && @end_date
        available_dates = n3rgy_api.readings_available_date_range(@meter.mpan_mprn, @meter.fuel_type)
        current_dates = readings_current_date_range(@meter)
      end

      start_date = @start_date || Amr::N3rgyDownloaderDates.start_date(available_dates, current_dates)
      end_date = @end_date || Amr::N3rgyDownloaderDates.end_date(available_dates)

      import_log = create_import_log
      readings = N3rgyDownloader.new(meter: @meter, start_date: start_date, end_date: end_date, n3rgy_api: n3rgy_api).readings
      N3rgyReadingsUpserter.new(meter: @meter, config: @config, readings: readings, import_log: import_log).perform
    rescue => e
      import_log.update!(error_messages: "Error downloading data from #{start_date} to #{end_date} : #{e.message}")
      Rails.logger.error "Exception: downloading N3rgy data for #{@meter.mpan_mprn} from #{start_date} to #{end_date} : #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :n3rgy_download, meter_id: @meter.mpan_mprn, start_date: start_date, end_date: end_date)
    end

    private

    def n3rgy_api
      @n3rgy_api ||= @n3rgy_api_factory.data_api(@meter)
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
        (Date.parse(first)..Date.parse(last))
      end
    end
  end
end
