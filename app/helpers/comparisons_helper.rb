module ComparisonsHelper
  # Calculate percentage change across two values or sum of values in two arrays
  def percent_change(base, new_val, to_nil_if_sum_zero = false)
    return nil if to_nil_if_sum_zero && sum_data(base) == 0.0
    return 0.0 if sum_data(base) == 0.0
    change = (sum_data(new_val) - sum_data(base)) / sum_data(base)
    to_nil_if_sum_zero && change == 0.0 ? nil : change
  end

  def sum_data(data, to_nil_if_sum_zero = false)
    data = Array(data)
    data.map! { |value| value || 0.0 } # create array 1st to avoid statsample map/sum bug
    val = data.sum
    to_nil_if_sum_zero && val == 0.0 ? nil : val
  end
end
