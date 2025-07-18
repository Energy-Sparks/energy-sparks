# Chart Manager drilldown
# - given and existing chart, and drilldown, returns a drilldown chart
class ChartManager
  include Logging

  def drilldown(old_chart_name, chart_config_original, series_name, x_axis_range)
    chart_config = resolve_chart_inheritance(chart_config_original)

    chart_config[:parent_chart_xaxis_config] = chart_config[:timescale] # save for front end 'up/back' button text

    chart_config.delete(:reverse_xaxis) # benchmark charts reverse the x-axis order, long-term charts then inherit this behaviour, negate on drilldown

    if chart_config[:chart1_type] == :scatter
      chart_config[:chart1_type] = :column
      chart_config[:series_breakdown] = :none
      chart_config.delete(:filter)
      chart_config.delete(:trendlines)
    end

    if %i[cusum hotwater heating].include?(chart_config[:series_breakdown])

      # these special case may need reviewing if we decide to aggregate
      # these types of graphs by anything other than days
      # therefore create a single date datetime drilldown

      chart_config[:chart1_type] = :column
      chart_config[:series_breakdown] = :none
    elsif chart_config[:series_breakdown] == :baseload
      # maintain as line chart, but present intraday profile
      # as baseload is aonly a single value not 48 x 1/2 hour values
      chart_config[:series_breakdown] = :none
    else
      chart_config.delete(:inject)

      unless series_name.nil?
        new_filter = drilldown_series_name(chart_config, series_name)
        chart_config = chart_config.merge(new_filter)
      end

      chart_config[:chart1_type] = :column if chart_config[:chart1_type] == :bar
    end

    unless x_axis_range.nil?
      new_timescale_x_axis = drilldown_daterange(chart_config, x_axis_range)
      chart_config = chart_config.merge(new_timescale_x_axis)
    end

    new_chart_name = (old_chart_name.to_s + '_drilldown').to_sym

    chart_config[:name] = drilldown_title(chart_config, series_name)

    reformat_dates(chart_config)

    [new_chart_name, chart_config]
  end

  def parent_chart_timescale_description(chart_config)
    return nil if !chart_config.key?(:parent_chart_xaxis_config) # || chart_config[:parent_chart_xaxis_config].nil?

    # unlimited i.e. long term charts have no timescale, so set to :years
    timescale = chart_config[:parent_chart_xaxis_config].nil? ? :years : chart_config[:parent_chart_xaxis_config]
    ChartTimeScaleDescriptions.interpret_timescale_description(timescale)
  end

  def drilldown_series_name(chart_config, series_name)
    existing_filter = chart_config.key?(:filter) ? chart_config[:filter] : {}
    existing_filter[chart_config[:series_breakdown]] = series_name
    new_filter = { filter: existing_filter }
  end

  def drilldown_daterange(chart_config, x_axis_range)
    new_x_axis = x_axis_drilldown(chart_config[:x_axis])
    if new_x_axis.nil?
      raise EnergySparksBadChartSpecification.new("Illegal drilldown requested for #{chart_config[:name]}  call drilldown_available first")
    end

    date_range_config = {
      timescale: { daterange: x_axis_range[0]..x_axis_range[1] },
      x_axis: new_x_axis
    }
  end

  def drilldown_available?(chart_config_original)
    # drilling down on comparison charts rarely makes sense
    # and the date ranges stop matching for example Mondays to Mondays
    return false if comparison_chart?(chart_config_original)

    drilldown_available(chart_config_original)
  end

  def drilldown_available(chart_config_original)
    chart_config = resolve_chart_inheritance(chart_config_original)

    drilldown?(chart_config) &&
    !fuel_breakdown_chart?(chart_config_original) &&
    !seasonal_analysis_drilled_down_to_far?(chart_config)
  end

  def x_axis_drilldown(existing_x_axis_config)
    case existing_x_axis_config
    when :year, :academicyear
      :week
    when :month, :week, :schoolweek, :workweek, :hotwater, :daterange
      :day
    when :day
      :datetime
    when :datetime, :dayofweek, :intraday, :nodatebuckets
      nil
    else
      raise EnergySparksBadChartSpecification.new("Unhandled x_axis drilldown config #{existing_x_axis_config}")
    end
  end

  private

  def drilldown?(chart_config)
    !x_axis_drilldown(chart_config[:x_axis]).nil?
  end

  def fuel_breakdown_chart?(chart_config)
    chart_config[:series_breakdown] == :fuel
  end

  def seasonal_analysis_drilled_down_to_far?(chart_config)
    chart_config[:series_breakdown] == :heating &&
    x_axis_drilldown(chart_config[:x_axis]) == :datetime
  end

  def comparison_chart?(chart_config)
    chart_config.key?(:timescale) &&
    chart_config[:timescale].is_a?(Array) &&
    chart_config[:timescale].length > 1
  end

  def drilldown_title(chart_config, series_name)
    if chart_config.key?(:drilldown_name)
      index = chart_config[:drilldown_name].index(chart_config[:name])
      if !index.nil? && index < chart_config[:drilldown_name].length - 1
        chart_config[:drilldown_name][index + 1]
      else
        chart_config[:drilldown_name][0]
      end
    else
      chart_config[:name]
    end
  end

  def reformat_dates(chart_config)
    if !chart_config[:x_axis].nil? && !%i[day datetime dayofweek intraday nodatebuckets datetime].include?(chart_config[:x_axis])
      chart_config[:x_axis_reformat] = { date: '%d %b %Y' }
    elsif !chart_config[:x_axis].nil? && %i[day].include?(chart_config[:x_axis])
      chart_config[:x_axis_reformat] = { date: '%A %d %b %Y' }
    elsif chart_config.key?(:x_axis_reformat)
      chart_config.delete(:x_axis_reformat)
    end
  end
end
