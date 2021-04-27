module Amr
  class N3rgyTariffsDownloadAndUpsert
    def initialize(meter:, start_date:, end_date:, n3rgy_api_factory: Amr::N3rgyApiFactory.new)
      @meter = meter
      @n3rgy_api_factory = n3rgy_api_factory
      @start_date = start_date
      @end_date = end_date
    end

    def perform
      start_date = @start_date || available_dates.first
      end_date = @end_date || available_dates.last
      import_log = create_import_log(start_date, end_date)
      tariffs = N3rgyDownloader.new(meter: @meter, start_date: start_date, end_date: end_date, n3rgy_api: n3rgy_api).tariffs
      N3rgyTariffsUpserter.new(meter: @meter, tariffs: tariffs, import_log: import_log).perform
    rescue => e
      import_log.update!(error_messages: "Error downloading tariffs from #{start_date} to #{end_date} : #{e.message}")
      Rails.logger.error "Exception: downloading N3rgy tariffs for #{@meter.mpan_mprn} from #{start_date} to #{end_date} : #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :n3rgy_download, meter_id: @meter.mpan_mprn, start_date: start_date, end_date: end_date)
    end

    private

    def n3rgy_api
      @n3rgy_api ||= @n3rgy_api_factory.data_api(@meter)
    end

    def available_dates
      @available_dates ||= (n3rgy_api.tariffs_available_date_range(@meter.mpan_mprn, @meter.fuel_type) || default_date_range)
    end

    def default_date_range
      start_date = Time.zone.today - 13.months
      end_date = Time.zone.today - 1
      (start_date..end_date)
    end

    def create_import_log(start_date, end_date)
      TariffImportLog.create(
        source: 'n3rgy-api',
        description: "Tariff import for #{@meter.mpan_mprn} at #{DateTime.now.utc}",
        start_date: start_date,
        end_date: end_date,
        import_time: DateTime.now.utc)
    end
  end
end
