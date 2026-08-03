# frozen_string_literal: true

module Amr
  class N3rgyEnergyTariffLoader
    def initialize(meter:)
      @meter = meter
    end

    def perform
      return unless @meter.dcc_meter_smets2? && @meter.consent_granted

      current_n3rgy_tariff = N3rgyTariffDownloader.new(meter: @meter).current_tariff
      N3rgyTariffManager.new(meter: @meter, current_n3rgy_tariff:, import_log:).perform
    rescue StandardError => e
      import_log.update!(error_messages: "Exception: downloading N3rgy tariffs for #{@meter.mpan_mprn}: " \
                                         "#{e.class} #{e.message}")
      EnergySparks::Log.exception(e, job: :n3rgy_energy_tariffs, meter_mpan: @meter.mpan_mprn)
    end

    private

    def import_log
      now = DateTime.now.utc
      @import_log ||= TariffImportLog.create!(source: 'n3rgy-api',
                                              description: "Tariff import for #{@meter.mpan_mprn} at #{now}",
                                              import_time: now)
    end
  end
end
