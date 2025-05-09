# TODO(PH, 30Mar2022): reconsider implementation, whether derived from Struct, OpenStruct or Hash
class AggregatorConfig < OpenStruct
  def config_none_or_nil?(config_key)
    !key?(config_key) || self[config_key].nil? || self[config_key] == :none
  end

  def include_benchmark?
    !config_none_or_nil?(:benchmark)
  end

  def benchmark_calculation_types
    dig(:benchmark, :calculation_types)
  end

  def benchmark_override(school_name)
    return {} if dig(:benchmark, :calculation_types).nil? || dig(:benchmark, :config).nil?

    calc_types = dig(:benchmark, :calculation_types).map(&:to_s)

    return {} unless calc_types.include?(school_name)

    dig(:benchmark, :config)
  end

  def daterange_subtitle?
    dig(:subtitle) == :daterange
  end

  def ignore_single_series_failure?
    key?(:ignore_single_series_failure) && dig(:ignore_single_series_failure)
  end

  def inject_benchmark?
    dig(:inject) == :benchmark
  end

  def series_breakdown?
    !series_breakdown.nil?
  end

  def series_breakdown
    dig(:series_breakdown)
  end

  def yaxis_units
    dig(:yaxis_units)
  end

  def yaxis_scaling
    dig(:yaxis_scaling)
  end

  def scale_y_axis?
    !dig(:scale_y_axis).nil? && dig(:scale_y_axis) != false
  end

  def scale_y_axis
    dig(:scale_y_axis)
  end

  def name
    dig(:name)
  end

  def yaxis_units_in_kw?
    yaxis_units == :kw
  end

  def nullify_trailing_zeros?
    dig(:nullify_trailing_zeros) == true
  end

  def cumulative?
    dig(:cumulative) == true
  end

  def reverse_name_order?
    key?(:series_name_order) && dig(:series_name_order) == :reverse
  end

  def reverse_xaxis?
    key?(:reverse_xaxis) && dig(:reverse_xaxis) == true
  end

  def x_axis_reformat?
    key?(:x_axis_reformat) && !dig(:x_axis_reformat).nil?
  end

  def x_axis_reformat
    dig(:x_axis_reformat)
  end

  def add_daycount_to_legend?
    key?(:add_day_count_to_legend) && dig(:add_day_count_to_legend) == true
  end

  def humanize_legend?
    key?(:humanize_legend) && dig(:humanize_legend) && Object.const_defined?('Rails')
  end

  def relabel_legend?
    # NOTE: set to a value:
    key?(:replace_series_label) && dig(:replace_series_label)
  end

  def replace_series_label
    dig(:replace_series_label)
  end

  def chart1_type
    dig(:chart1_type)
  end

  def y2_axis?
    !y2_axis.nil? && y2_axis != :none
  end

  def y2_axis
    dig(:y2_axis)
  end

  def temperature_compensation_hash?
    adjust_by_temperature? &&
      dig(:adjust_by_temperature).is_a?(Hash) &&
      !key?(:temperature_adjustment_map)
  end

  def month_comparison?
    return false unless array_of_timescales?
    return false unless timescale.length > 1
    return false unless %i[month month_excluding_year].include?(x_axis)

    allowed = %i[up_to_a_year twelve_months academicyear fixed_academic_year]
    timescale.all? { |scale| scale.is_a?(Hash) && allowed.include?(scale.keys[0]) }
  end

  def x_axis
    dig(:x_axis)
  end

  def half_hourly_x_axis?
    x_axis == :datetime || x_axis == :intraday
  end

  def adjust_by_temperature?
    !dig(:adjust_by_temperature).nil?
  end

  def include_target?
    !config_none_or_nil?(:target)
  end

  def target_calculation_type
    dig(:target, :calculation_type)
  end

  def extend_chart_into_future?
    dig(:target, :extend_chart_into_future) == true
  end

  def truncate_before_start_date?
    dig(:target, :truncate_before_start_date) == true
  end

  def sort_by?
    !sort_by.nil?
  end

  def sort_by
    dig(:sort_by)
  end

  def show_only_target_school?
    dig(:target, :show_target_only) == true
  end

  def timescale?
    !timescale.nil?
  end

  def timescale
    dig(:timescale)
  end

  def array_of_timescales?
    timescale? && timescale.is_a?(Array)
  end

  def add_daycount_to_legend?
    flag_is_true?(:add_day_count_to_legend)
  end

  def heating_daytype_filter?
    has_filter?(:heating_daytype)
  end

  def daytype_filter?
    has_filter?(:daytype)
  end

  def day_type_filter
    dig(:filter, :daytype)
  end

  def heating_filter?
    has_filter?(:heating)
  end

  def heating_filter
    dig(:filter, :heating)
  end

  def model_type_filter?
    has_filter?(:model_type)
  end

  def model_type_filters
    dig(:filter, :model_type)
  end

  def filter_by_type(filter_type)
    dig(:filter, filter_type)
  end

  def filters
    dig(:filter)
  end

  def submeter_filter?
    has_filter?(:submeter)
  end

  def submeter_filter
    dig(:filter, :submeter)
  end

  def chart_has_filter?
    !config_none_or_nil?(:filter)
  end

  def has_filter?(type)
    chart_has_filter? && filter.key?(type) && !filter[type].nil?
  end

  # TODO)PH, 30Mar2022) make key private once SeriesDataManager has been upgraded to use new interfaces
  # slow? - is there a better way of doing this?
  def key?(k)
    to_h.key?(k)
  end

  private

  def flag_is_true?(k)
    key?(k) && send(k)
  end
end
