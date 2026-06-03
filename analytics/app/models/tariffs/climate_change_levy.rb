# frozen_string_literal: true

require 'date'

class ClimateChangeLevy
  class MissingClimateChangeLevyData < StandardError; end

  # https://www.gov.uk/guidance/climate-change-levy-rates
  DEFAULT_RATES = {
    electricity: {
      Date.new(2018, 4, 1)..Date.new(2019, 3, 31) => 0.00583,
      Date.new(2019, 4, 1)..Date.new(2020, 3, 31) => 0.00847,
      Date.new(2020, 4, 1)..Date.new(2021, 3, 31) => 0.00811,
      Date.new(2021, 4, 1)..Date.new(2022, 3, 31) => 0.00775,
      Date.new(2022, 4, 1)..Date.new(2023, 3, 31) => 0.00775,
      Date.new(2023, 4, 1)..Date.new(2024, 3, 31) => 0.00775,
      Date.new(2024, 4, 1)..Date.new(2025, 3, 31) => 0.00775,
      Date.new(2025, 4, 1)..Date.new(2026, 3, 31) => 0.00775,
      Date.new(2026, 4, 1)..Date.new(2027, 3, 31) => 0.00801,
      Date.new(2027, 4, 1)..Date.new(2028, 3, 31) => 0.00827
    },
    gas: {
      Date.new(2018, 4, 1)..Date.new(2019, 3, 31) => 0.00203,
      Date.new(2019, 4, 1)..Date.new(2020, 3, 31) => 0.00339,
      Date.new(2020, 4, 1)..Date.new(2021, 3, 31) => 0.00406,
      Date.new(2021, 4, 1)..Date.new(2022, 3, 31) => 0.00465,
      Date.new(2022, 4, 1)..Date.new(2023, 3, 31) => 0.00568,
      Date.new(2023, 4, 1)..Date.new(2024, 3, 31) => 0.00672,
      Date.new(2024, 4, 1)..Date.new(2025, 3, 31) => 0.00775,
      Date.new(2025, 4, 1)..Date.new(2026, 3, 31) => 0.00775,
      Date.new(2026, 4, 1)..Date.new(2027, 3, 31) => 0.00801,
      Date.new(2027, 4, 1)..Date.new(2028, 3, 31) => 0.00827
    }
  }.freeze

  def self.rate(fuel_type, date)
    check_levy_set(fuel_type, date)

    rate_range = DEFAULT_RATES[fuel_type].select do |date_range, _rate|
      # much faster than ruby matching as by default it scans the date range incrementally
      date >= date_range.first && date <= date_range.last
    end

    if rate_range.nil? || rate_range.empty?
      [:climate_change_levy, 0.0]
    else
      [:climate_change_levy, rate_range.values[0]]
    end
  end

  private_class_method def self.check_levy_set(fuel_type, date)
    return unless date > DEFAULT_RATES[fuel_type].keys.map(&:last).max

    raise MissingClimateChangeLevyData, "Internal Error: climate change levy not set for #{date}"
  end
end
