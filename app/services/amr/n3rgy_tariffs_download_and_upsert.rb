module Amr
  class N3rgyTariffsDownloadAndUpsert
    def initialize(meter:, n3rgy_api_factory: Amr::N3rgyApiFactory.new)
      @meter = meter
      @n3rgy_api_factory = n3rgy_api_factory
      @start_date = DateTime.now.yesterday.beginning_of_day
      @end_date = DateTime.now.beginning_of_day # Error for same day <MeterReadingsFeeds::N3rgyDataApi::ApiFailure: Parameter 'start' must represent a date before parameter 'end'.>
    end

    def perform
      N3rgyTariffsUpserter.new(meter: @meter, tariffs: tariffs, import_log: import_log).perform
    rescue => e
      import_log.update!(error_messages: "Error downloading tariffs from #{@start_date} to #{@end_date} : #{e.message}") if import_log
      Rails.logger.error "Exception: downloading N3rgy tariffs for #{@meter.mpan_mprn} from #{@start_date} to #{@end_date} : #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :n3rgy_download, meter_id: @meter.mpan_mprn, start_date: @start_date, end_date: @end_date)
    end

    private

    def tariffs
      N3rgyDownloader.new(meter: @meter, start_date: @start_date, end_date: @end_date, n3rgy_api: n3rgy_api).tariffs
    end

    def n3rgy_api
      @n3rgy_api ||= @n3rgy_api_factory.data_api(@meter)
    end

    def import_log
      @import_log ||= TariffImportLog.create!(
        source: 'n3rgy-api',
        description: "Tariff import for #{@meter.mpan_mprn} at #{DateTime.now.utc}",
        start_date: @start_date,
        end_date: @end_date,
        import_time: DateTime.now.utc)
    end
  end
end
