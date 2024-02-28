module Amr
  class N3rgyTariffManager
    def initialize(meter:, current_n3rgy_tariff:, import_log:)
      @meter = meter
      @current_n3rgy_tariff = current_n3rgy_tariff
      @import_log = import_log
      @energy_tariff = latest_energy_tariff
    end

    def perform
      # n3rgy tariffs will be nil if no tariffs have been stored on the
      # meter, tariffs are in an unsupported format, or other problems
      # parsing response.
      #
      # In this case consider any existing tariff to have ended
      expire_existing_tariff && return if @current_n3rgy_tariff.nil?

      if @energy_tariff.nil? || tariff_changed?
        create_new_tariff
        expire_existing_tariff
      end
    end

    private

    def latest_energy_tariff
      @meter.energy_tariffs.dcc.where(end_date: nil).order(created_at: :desc).first
    end

    def expire_existing_tariff
      return unless @energy_tariff.present?
      @energy_tariff.update!(end_date: Time.zone.yesterday)
    end

    # Change means:
    #  Different type of tariff
    #  Different standing charge, but same type of tariff
    #  Different prices, but same type of tariff
    #  Different differential periods
    def tariff_changed?
      return true unless same_tariff_type?
      return true unless same_standing_charge?
      return true unless same_prices?
      false
    end

    def same_tariff_type?
      @energy_tariff.flat_rate? && @current_n3rgy_tariff[:flat_rate].present?
    end

    def same_standing_charge?
      @energy_tariff.energy_tariff_charges.where(charge_type: :standing_charge, value: @current_n3rgy_tariff[:standing_charge], units: :day).any?
    end

    # Should already have checked if existing and new tariff are same type
    def same_prices?
      if @energy_tariff.flat_rate?
        @energy_tariff.energy_tariff_prices.first.value == @current_n3rgy_tariff[:flat_rate]
      elsif @energy_tariff.energy_tariff_prices.count == @current_n3rgy_tariff[:differential].values
        @current_n3rgy_tariff[:differential].each_value do |period|
          return false unless energy_tariff.energy_tariff_prices.where(
            start_time: to_time(period[:start_time]),
            end_time: to_time(period[:end_time]),
            value: period[:value]).any?
        end
      else
        false
      end
    end

    def to_time(time)
      hours, mins = time.split(':')[0, 1]
      Time.zone.local(2000, 1, 1, hours, mins)
    end

    def create_new_tariff
      EnergyTariff.create!(
        ccl: false,
        enabled: true,
        end_date: nil,
        meter_type: @meter.meter_type,
        name: "Tariff from SMETS2 meter #{@meter.mpan_mprn}",
        source: :dcc,
        start_date: Time.zone.yesterday,
        tariff_holder: @meter.school,
        tariff_type: @current_n3rgy_tariff[:flat_rate].present? ? :flat_rate : :differential,
        tnuos: false,
        vat_rate: nil,
        energy_tariff_prices: energy_tariff_prices,
        energy_tariff_charges: energy_tariff_charges,
        meters: [@meter]
      )
    end

    def energy_tariff_prices
      if @current_n3rgy_tariff[:flat_rate]
        [EnergyTariffPrice.new(
          units: :kwh,
          value: @current_n3rgy_tariff[:flat_rate]
        )]
      else
        @current_n3rgy_tariff[:differential].map do |period|
          EnergyTariffPrice.new(
            start_time: to_time(period[:start_time]),
            end_time: to_time(period[:end_time]),
            units: period[:units],
            value: period[:value]
          )
        end
      end
    end

    def energy_tariff_charges
      [
        EnergyTariffCharge.new(
          charge_type: :standing_charge,
          value: @current_n3rgy_tariff[:standing_charge],
          units: :day
        )
      ]
    end
  end
end
