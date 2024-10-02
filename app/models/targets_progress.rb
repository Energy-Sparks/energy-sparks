class TargetsProgress
  attr_reader :fuel_type

  def initialize(fuel_type:, months:, monthly_targets_kwh:, monthly_usage_kwh:, monthly_performance:,
                                      cumulative_targets_kwh:, cumulative_usage_kwh:, cumulative_performance:,
                                      monthly_performance_versus_synthetic_last_year:, cumulative_performance_versus_synthetic_last_year:, partial_months:, percentage_synthetic:)
    @fuel_type = fuel_type
    @months = months
    @monthly_targets_kwh = monthly_targets_kwh
    @monthly_usage_kwh = monthly_usage_kwh
    @monthly_performance = monthly_performance
    @cumulative_targets_kwh = cumulative_targets_kwh
    @cumulative_usage_kwh = cumulative_usage_kwh
    @cumulative_performance = cumulative_performance
    @monthly_performance_versus_synthetic_last_year = monthly_performance_versus_synthetic_last_year
    @cumulative_performance_versus_synthetic_last_year = cumulative_performance_versus_synthetic_last_year
    @partial_months = partial_months
    @percentage_synthetic = percentage_synthetic
  end

  def monthly_targets_kwh
    to_keyed_collection(months, @monthly_targets_kwh)
  end

  def monthly_usage_kwh
    to_keyed_collection(months, @monthly_usage_kwh)
  end

  def monthly_performance
    to_keyed_collection(months, @monthly_performance)
  end

  def monthly_performance_versus_synthetic_last_year
    to_keyed_collection(months, @monthly_performance_versus_synthetic_last_year)
  end

  def cumulative_targets_kwh
    to_keyed_collection(months, @cumulative_targets_kwh)
  end

  def percentage_synthetic
    to_keyed_collection(months, @percentage_synthetic)
  end

  def cumulative_usage_kwh
    to_keyed_collection(months, @cumulative_usage_kwh)
  end

  def current_cumulative_usage_kwh
    @cumulative_usage_kwh.compact.last
  end

  def cumulative_performance
    to_keyed_collection(months, @cumulative_performance)
  end

  def current_cumulative_performance
    @cumulative_performance.compact.last
  end

  def cumulative_performance_versus_synthetic_last_year
    to_keyed_collection(months, @cumulative_performance_versus_synthetic_last_year)
  end

  def current_cumulative_performance_versus_synthetic_last_year
    @cumulative_performance_versus_synthetic_last_year.compact.last
  end

  #Used to colour code the readings
  def partial_months
    to_keyed_collection(months, @partial_months)
  end

  def months
    @months
  end

  #do we have partial data for any months?
  #if so we'll display a footnote
  def partial_consumption_data?
    @partial_months.any?(true)
  end

  #have we only been able to generate targets for some months?
  #e.g. due to lack of historical data or no estimate?
  def partial_target_data?
    @monthly_targets_kwh.any?(nil)
  end

  #does the reporting period start before we have consumption data?
  #if so, we'll display a footnote
  def reporting_period_before_consumption_data?
    @monthly_usage_kwh.first.nil?
  end

  #are any of the monthly targets calculated from estimated data, rather than
  #real consumption?
  def targets_derived_from_synthetic_data?
    @percentage_synthetic.any? {|v| v > 0.0 }
  end

  private

  def to_keyed_collection(keys, data)
    ret = {}
    keys.each_with_index do |key, idx|
      ret[key] = data[idx]
    end
    ret
  end
end
