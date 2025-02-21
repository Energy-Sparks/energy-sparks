class AggregatorPostProcess < AggregatorBase
  def initialize(multi_school_periods)
    super(multi_school_periods.school, multi_school_periods.chart_config, multi_school_periods.results)
  end

  def calculate
    inject_benchmarks                   if chart_config.inject_benchmark?

    series_filter.filter                if chart_config.chart_has_filter? && chart_config.series_breakdown != :none

    create_y2_axis_data                 if chart_config.y2_axis?

    reorganise_buckets                  if chart_config.chart1_type == :scatter

    scale_y_axis_to_kw                  if chart_config.yaxis_units_in_kw?

    nullify_trailing_zeros              if chart_config.nullify_trailing_zeros?

    accumulate_data                     if chart_config.cumulative?

    reverse_series_name_order(:reverse) if chart_config.reverse_name_order?

    reverse_x_axis                      if chart_config.reverse_xaxis?

    reformat_x_axis                     if chart_config.x_axis_reformat?

    mark_up_legend_with_day_count       if chart_config.add_daycount_to_legend?

    humanize_legend                     if chart_config.humanize_legend?

    relabel_legend                      if chart_config.relabel_legend?

    set_y_axis_label

    swap_NaN_for_nil
  end

  private

  def series_filter
    @series_filter ||= Charts::Filters::SeriesFilter.new(school, chart_config, results)
  end

  def inject_benchmarks
    bm = AggregatorBenchmarks.new(school, chart_config, results)
    bm.inject_benchmarks
  end

  def create_y2_axis_data
    # move bucketed data to y2 axis if configured that way
    results.y2_axis = {}
    logger.debug "Moving #{chart_config.y2_axis} onto Y2 axis"
    pattern_match_y2_axis_names.each do |series_name|
      results.y2_axis[series_name] = results.bucketed_data[series_name]
      results.bucketed_data.delete(series_name)
    end
  end

  # need to deal with case where multiple merged charts and date or school suffix has been added to the end of the series name
  def pattern_match_y2_axis_names
    matched = []
    Series::ManagerBase.y2_series_types.values.each do |y2_series_name|
      base_name_length = y2_series_name.length
      matched += results.bucketed_data.keys.select{ |bucket_name| bucket_name[0...base_name_length] == y2_series_name }
    end
    matched
  end

    # this is a bit of a fudge, the data from a thermostatic scatter aggregation comes out
  # in the wrong order by default for most graphing packages, so the columns of data need
  # reorganising
  def reorganise_buckets
    dd_or_temp_key = results.bucketed_data.key?(Series::DegreeDays::DEGREEDAYS) ? Series::DegreeDays::DEGREEDAYS : Series::Temperature::TEMPERATURE
    # replace dates on x axis with degree days, but retain them for future point labelling
    x_axis = results.x_axis
    results.x_axis = results.bucketed_data[dd_or_temp_key]
    results.x_axis_bucket_date_ranges = results.xbucketor.x_axis_bucket_date_ranges
    results.bucketed_data.delete(dd_or_temp_key)
    # insert dates back in as 'silent' y2_axis
    results.data_labels = x_axis
    results.x_axis_label = dd_or_temp_key
  end

    # kw to kwh scaling is slightly painful as you need to know how many buckets
  # the scaling factor code which is used in the initial seriesdatamanager bucketing
  # already multiplies the kWh by 2, to scale from 1/2 hour to 1 hour
  def scale_y_axis_to_kw
    results.bucketed_data.each do |series_name, data|
      (0..data.length - 1).each do |index|
        date_range = results.xbucketor.x_axis_bucket_date_ranges[index]
        days = date_range[1] - date_range[0] + 1.0
        if chart_config.half_hourly_x_axis?
          # intraday kwh data gets bucketed into 48 x 1/2 hour buckets
          # kw = kwh in bucket / dates in bucket * 2 (kWh per 1/2 hour)
          count = results.bucketed_data_count[series_name][index]
          # rubocop:disable Style/ConditionalAssignment
          if count > 0
            results.bucketed_data[series_name][index] = 2 * results.bucketed_data[series_name][index] / count
          else
            results.bucketed_data[series_name][index] = 0
          end
          # rubocop:enable Style/ConditionalAssignment
        else
          results.bucketed_data[series_name][index] /= results.bucketed_data_count[series_name][index]
        end
      end
    end
  end

  def nullify_trailing_zeros
    results.bucketed_data.keys.each do |series_name|
      got_non_zero_value = false
      reorged_values = results.bucketed_data[series_name].reverse.map do |val|
        got_non_zero_value = true if val != 0.0
        val == 0.0 && !got_non_zero_value ? nil : val
      end
      results.bucketed_data[series_name] = reorged_values.reverse
    end
  end

  def accumulate_data
    results.bucketed_data.keys.each do |series_name|
      running_total = 0.0
      results.bucketed_data[series_name].map! do |val|
        val.nil? ? nil : (running_total += val)
      end
    end
  end

  def reverse_series_name_order(format)
    if format.is_a?(Symbol) && format == :reverse
      results.bucketed_data = results.bucketed_data.to_a.reverse.to_h
      results.bucketed_data_count = results.bucketed_data.to_a.reverse.to_h
    elsif format.is_a?(Array) # TODO(PH,22Jul2018): written but not tested, by be useful in future
      data = {}
      count = {}
      format.each do |series_name|
        data[series_name] = results.bucketed_data[series_name]
        count[series_name] = results.bucketed_data_count[series_name]
      end
      results.bucketed_data = data
      results.bucketed_data_count = count
    end
  end

  def reverse_x_axis
    results.x_axis = results.x_axis.reverse
    results.x_axis_bucket_date_ranges = results.x_axis_bucket_date_ranges.reverse

    results.bucketed_data.each_key do |series_name|
      results.bucketed_data[series_name] = results.bucketed_data[series_name].reverse
      results.bucketed_data_count[series_name] = results.bucketed_data_count[series_name].reverse
    end

    unless results.y2_axis.nil?
      results.y2_axis.each_key do |series_name|
        results.y2_axis[series_name] = results.y2_axis[series_name].reverse
      end
    end
  end

  def reformat_x_axis
    format = chart_config.x_axis_reformat
    if format.is_a?(Hash) && format.key?(:date)
      results.x_axis.map! { |date| date.is_a?(String) ? date : I18n.l(date, format: format[:date]) }
    else
      raise EnergySparksBadChartSpecification.new("Unexpected x axis reformat chart configuration #{format}")
    end
  end

  def mark_up_legend_with_day_count
    results.bucketed_data.keys.each do |series_name|
      days = results.bucketed_data_count[series_name].sum
      new_series_name = series_name + " (#{days} days)"
      results.bucketed_data[new_series_name] = results.bucketed_data.delete(series_name)
      results.bucketed_data_count[new_series_name] = results.bucketed_data_count.delete(series_name)
    end
  end

  def humanize_legend
    results.bucketed_data.keys.each do |series_name|
      new_series_name = series_name.to_s.humanize
      results.bucketed_data[new_series_name] = results.bucketed_data.delete(series_name)
      results.bucketed_data_count[new_series_name] = results.bucketed_data_count.delete(series_name)
    end
  end

  def relabel_legend
    chart_config.replace_series_label.each do |substitute_pair|
      results.bucketed_data.keys.each do |series_name|
        original    = substitute_pair[0]
        replacement = substitute_pair[1]
        original = original.gsub('<school_name>', school.name) if original.include?('<school_name>')
        new_series_name = series_name.gsub(original, replacement)
        results.bucketed_data[new_series_name] = results.bucketed_data.delete(series_name)
        results.bucketed_data_count[new_series_name] = results.bucketed_data_count.delete(series_name)
      end
    end
  end

  def set_y_axis_label
    results.set_y_axis_label(y_axis_label(nil))
  end

  def y_axis_label(value)
    YAxisScaling.unit_description(chart_config.yaxis_units, chart_config.yaxis_scaling, value)
  end

    # the analytics code treats missing and incorrectly calculated numbers as NaNs
  # unforunately the front end (Rails) prefers nil, so post process the entire
  # result set if running for rails to swap NaN for nil
  # analytics more performant in mainly using NaNs, as fewer tests required
  # e.g. total += value versus if total.nil? ? total = value : (value.nil? ? nil : total + value)
  def swap_NaN_for_nil
    return if results.bucketed_data.nil?
    results.bucketed_data.each do |series_name, result_data|
      unless result_data.is_a?(Symbol)
        results.bucketed_data[series_name] = result_data.map do |x|
          x = x.to_f if is_a?(Integer)
          (x.nil? || x.finite?) ? x : nil
        end
      end
    end
  end
end
