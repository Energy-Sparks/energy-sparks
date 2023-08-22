module Amr
  class N3rgyEnergyTariffLoader
    def initialize(meter:, n3rgy_api_factory: Amr::N3rgyApiFactory.new)
      @meter = meter
      @n3rgy_api_factory = n3rgy_api_factory
    end

    def perform
      N3rgyEnergyTariffsInserter.new(
        meter: @meter,
        start_date: start_date,
        tariff: download_todays_tariff,
        import_log: import_log).perform
    rescue => e
      msg = "Exception: downloading N3rgy tariffs for #{@meter.mpan_mprn} from #{start_date} to #{end_date} : #{e.class} #{e.message}"
      import_log.update!(error_messages: msg) if import_log
      Rails.logger.error msg
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :n3rgy_energy_tariffs, meter_id: @meter.mpan_mprn, start_date: start_date, end_date: end_date)
    end

    private

    def start_date
      @start_date ||= DateTime.now.beginning_of_day
    end

    def end_date
      @end_date ||= DateTime.now.end_of_day
    end

    def download_todays_tariff
      N3rgyDownloader.new(meter: @meter, start_date: start_date, end_date: end_date, n3rgy_api: n3rgy_api).tariffs
    end

    def n3rgy_api
      @n3rgy_api ||= @n3rgy_api_factory.data_api(@meter)
    end

    def import_log
      @import_log ||= TariffImportLog.create!(
        source: 'n3rgy-api',
        description: "Tariff import for #{@meter.mpan_mprn} at #{DateTime.now.utc}",
        start_date: start_date,
        end_date: end_date,
        import_time: DateTime.now.utc)
    end
  end
end
