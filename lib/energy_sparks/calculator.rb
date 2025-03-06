module EnergySparks
  class Calculator
    # Calculate percentage change across two values or sum of values in two arrays
    def self.percent_change(base, new_val, to_nil_if_sum_zero = false)
      return nil if to_nil_if_sum_zero && sum_data(base) == 0.0
      return 0.0 if sum_data(base) == 0.0

      change = (sum_data(new_val) - sum_data(base)) / sum_data(base)
      to_nil_if_sum_zero && change == 0.0 ? nil : change
    end

    def self.sum_data(data, to_nil_if_sum_zero = false)
      data = Array(data)
      data.map! { |value| value || 0.0 } # create array 1st to avoid statsample map/sum bug
      val = data.sum
      to_nil_if_sum_zero && val == 0.0 ? nil : val
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
