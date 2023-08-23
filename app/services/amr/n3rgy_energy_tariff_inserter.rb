module Amr
  #This version makes some assumptions about what tariffs are
  #loaded. Specifically, that there is a single days tariff.
  #This is what v1 of the n3rgy API now supports.
  #
  #As a result the class ignores the date ranges returned by
  #the `N3rgyTariffs` class. It just relies on that to map
  #the list of prices into a more compressed representation
  #which consists of time of day ranges that can be used to
  #check the energy tariff prices
  class N3rgyEnergyTariffInserter
    def initialize(meter:, start_date:, tariff:, import_log:)
      @meter = meter
      @start_date = start_date
      @tariff = tariff
      @import_log = import_log
      @import_log_error_messages = []
    end

    def perform
      check_unexpected_tariff_format?
      energy_tariff = latest_energy_tariff

      if reject_as_zero_standing_charges? || reject_as_zero_tariffs?
        update_existing_tariff(energy_tariff)
        return
      end

      if energy_tariff.nil? || tariff_changed?(energy_tariff)
        create_new_tariff
        update_existing_tariff(energy_tariff)
      end
    end

    private

    def latest_energy_tariff
      @meter.energy_tariffs.dcc.where(end_date: nil).order(created_at: :desc).first
    end

    #Change means:
    #  Different type of tariff
    #  Different standing charge, but same type of tariff
    #  Different prices, but same type of tariff
    #  Different differential periods
    def tariff_changed?(energy_tariff)
      return true unless same_tariff_type?(energy_tariff)
      return true unless same_standing_charge?(energy_tariff)
      return true unless same_prices?(energy_tariff)
      false
    end

    def same_tariff_type?(energy_tariff)
      energy_tariff.flat_rate? && flat_rate?
    end

    def same_standing_charge?(energy_tariff)
      energy_tariff.energy_tariff_charges.where(charge_type: :standing_charge, value: standing_charge, units: :day).any?
    end

    #Should already have checked if existing and new tariff are
    #same type
    def same_prices?(energy_tariff)
      if energy_tariff.flat_rate?
        return energy_tariff.energy_tariff_prices.first.value == rates.values.first
      else
        return false unless energy_tariff.energy_tariff_prices.count == rates.keys.count
        rates.each do |times, price|
          return false unless energy_tariff.energy_tariff_prices.where(start_time: times.first.to_s, end_time: times.last.to_s, value: price).any?
        end
      end
      true
    end

    def flat_rate?
      rates.keys.count == 1
    end

    def standing_charge
      summary_tariff[:standing_charges].values.first
    end

    def reject_as_zero_standing_charges?
      if standing_charge <= 0.0
        log_error("Standing charge returned from n3rgy for #{@start_date} are zero #{standing_charge}")
        return true
      end
      false
    end

    def reject_as_zero_tariffs?
      if rates.values.all? { |price| price.is_a?(Numeric) && price <= 0.0 }
        log_error("Prices returned from n3rgy for #{@start_date} are zero #{rates.inspect}")
        @import_log.save!
        return true
      end
      false
    end

    #We only support flat rate and differential tariffs in the EnergyTariff
    #model currently. Raise exception to catch problems early
    def check_unexpected_tariff_format?
      unless rates.values.all? {|price| price.is_a?(Numeric)}
        raise "Unexpected tariff format for #{@meter.mpan_mprn} on #{@start_date}: #{rates.inspect}"
      end
      #Trigger parsing of tariff data, which may throw errors
      summary_tariff
    end

    #Returns structures like:
    #
    # Flat Rate:
    #
    # {00:00..23:30=>0.14168}
    #
    # Differential:
    #
    # {00:00..06:30=>0.0878, 07:00..22:30=>0.1629, 23:00..23:30=>0.0878}
    #
    # Tiered: not supported in new EnergyTariff model currently.
    #
    # {00:00..07:30=>0.4385, 08:00..19:30=>{0.0..1000.0=>0.48527, 1000.0..Infinity=>0.16774}, 20:00..23:30=>0.4385}}
    #
    # Keys are TimeOfDay30mins.
    def rates
      summary_tariff[:kwh_rates].values.first
    end

    def summary_tariff
      @summary_tariff ||= N3rgyTariffs.new(@tariff).parameterise
    end

    def end_date
      Time.zone.today - 1
    end

    def update_existing_tariff(energy_tariff)
      return unless energy_tariff.present?
      energy_tariff.update!(end_date: end_date)
    end

    def create_new_tariff
      EnergyTariff.create!(
        ccl: false,
        enabled: true,
        end_date: nil,
        meter_type: @meter.meter_type,
        name: "Tariff from DCC SMETS2 meter",
        source: :dcc,
        start_date: @start_date,
        tariff_holder: @meter.school,
        tariff_type: flat_rate? ? :flat_rate : :differential,
        tnuos: false,
        vat_rate: nil,
        energy_tariff_prices: energy_tariff_prices,
        energy_tariff_charges: energy_tariff_charges,
        meters: [@meter]
      )
    end

    #rubocop:disable Rails/Date
    def energy_tariff_prices
      rates.map do |time_range, price|
        EnergyTariffPrice.new(
          start_time: time_range.first.to_time,
          end_time: to_end_time(time_range.last, flat_rate?),
          units: :kwh,
          value: price
        )
      end
    end
    #rubocop:enable Rails/Date

    #rubocop:disable Rails/Date
    def to_end_time(time_of_day, flat_rate = true)
      flat_rate ? time_of_day.to_time : time_of_day.to_time.advance(minutes: 30)
    end
    #rubocop:enable Rails/Date

    def energy_tariff_charges
      [
        EnergyTariffCharge.new(
          charge_type: :standing_charge,
          value: standing_charge
        )
      ]
    end

    def log_error(msg)
      @import_log.error_messages = msg
      @import_log.save!
    end
  end
end
