# frozen_string_literal: true

module EnergySparksAnalyticsDataHelpers
  # Creates hash structure used to describe the rates in a flat rate tariff
  def create_flat_rate(rate: 0.15, standing_charge: nil, other_charges: {})
    rates = {
      flat_rate: {
        per: :kwh,
        rate: rate
      }
    }
    if standing_charge
      rates[:standing_charge] = {
        per: :day,
        rate: standing_charge
      }
    end
    rates.merge!(other_charges)
    rates
  end

  # Creates hash structure used to describe the rates in the current style of differential tariff
  # As used by GenericAccountingTariff
  def create_differential_rate(day_rate: 0.30, night_rate: 0.15, standing_charge: nil, other_charges: {})
    rates = {
      rate0: {
        from: TimeOfDay.new(7, 0),
        to: TimeOfDay.new(23, 30),
        per: :kwh,
        rate: night_rate
      },
      rate1: {
        from: TimeOfDay.new(0, 0),
        to: TimeOfDay.new(6, 30),
        per: :kwh,
        rate: day_rate
      }
    }
    if standing_charge
      rates[:standing_charge] = {
        per: :day,
        rate: standing_charge
      }
    end
    rates.merge!(other_charges)
    rates
  end

  # Creates the Hash structure used to describe different types of accounting tariff
  def create_accounting_tariff_generic(start_date: Date.yesterday, end_date: Date.today, name: "Tariff #{rand}",
                                       source: :manually_entered, tariff_holder: :site_settings, type: :flat, vat: '0%', created_at: DateTime.now, climate_change_levy: false, system_wide: nil, default: nil, rates: create_flat_rate)
    t = {
      start_date: start_date,
      end_date: end_date,
      name: name,
      source: source,
      type: type,
      tariff_holder: tariff_holder,
      created_at: created_at,
      vat: vat,
      climate_change_levy: climate_change_levy,
      rates: rates
    }
    t[:system_wide] = system_wide unless system_wide.nil?
    t[:default] = default unless default.nil?
    t
  end
end

# Allow factories to call the helpers
module FactoryBot
  class SyntaxRunner
    include EnergySparksAnalyticsDataHelpers
  end
end
