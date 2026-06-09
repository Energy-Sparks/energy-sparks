# frozen_string_literal: true

module EnergySparks
  class Calculator
    def self.percent_change(base, new_val)
      return nil if base.nil? || new_val.nil? || base.zero?

      (new_val - base) / base
    end

    def self.sum_data(data)
      data = Array(data)
      data.map! { |value| value || 0.0 } # create array 1st to avoid statsample map/sum bug
      data.sum
    end

    # Accepts 2 arrays of kwh, co2 or £ values.
    # Expects first 2 values of each array to be the electricity and gas values
    # Remainder of array can be storage heater and/or solar
    #
    # Only sums +previous_year_values+ if:
    #
    # - there are values for both electricity and gas in both years
    # - electricity (or gas) is missing in both years
    #
    # Returns nil if there's no values for gas/electricity in previous year, but there are
    # for the current year. As this indicates that the data coverage is incomplete and
    # summing the values would produce a misleading figure.
    #
    # Storage heater values are not checked because these are based on
    # electricity data and will be missing if the electricity is missing.
    #
    # Solar is not checked as panels may not have been installed until this year.
    #
    def self.sum_if_complete(previous_year_values, current_year_values)
      eg_prev = previous_year_values[0..1].map(&:nil?)
      eg_curr = current_year_values[0..1].map(&:nil?)

      return nil if eg_prev != eg_curr

      sum_data(previous_year_values)
    end
  end
end
