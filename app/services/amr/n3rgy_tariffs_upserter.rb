require 'dashboard'

module Amr
  class N3rgyTariffsUpserter
    def initialize(meter:, tariffs:, import_log:)
      @meter = meter
      @tariffs = tariffs
      @import_log = import_log
    end

    def perform
      return if @tariffs.empty?
      Rails.logger.info "Upserting #{kwh_tariffs} for #{@meter.mpan_mprn} at #{@meter.school.name}"
      TariffUpserter.new(prices_array(kwh_tariffs), standing_charges_array(standing_charges), @import_log).perform
      Rails.logger.info "Upserted #{@import_log.prices_updated} prices and #{@import_log.standing_charges_updated} standing charges for #{@meter.mpan_mprn} at #{@meter.school.name}"
      Rails.logger.info "Inserted #{@import_log.prices_imported} prices and #{@import_log.standing_charges_imported} standing charges for #{@meter.mpan_mprn} at #{@meter.school.name}"
    end

    private

    def kwh_tariffs
      @tariffs[:kwh_tariffs]
    end

    def standing_charges
      @tariffs[:standing_charges]
    end

    def prices_array(tariff_prices_hash)
      tariff_prices_hash.map do |tariff_date, prices|
        {
          meter_id: @meter.id,
          tariff_date: tariff_date,
          prices: prices
        }
      end
    end

    def standing_charges_array(standing_charges_hash)
      standing_charges_hash.map do |start_date, value|
        {
          meter_id: @meter.id,
          start_date: start_date,
          value: value
        }
      end
    end
  end
end
