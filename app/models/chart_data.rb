require 'dashboard'

class ChartData
  def initialize(aggregated_school, chart_type, show_benchmark_figures, custom_chart_config)
    @aggregated_school = aggregated_school
    @chart_type = chart_type
    @custom_chart_config = custom_chart_config
    @show_benchmark_figures = show_benchmark_figures
  end

  def data
    chart_manager = ChartManager.new(@aggregated_school, @show_benchmark_figures)
    chart_config = customised_chart_config(chart_manager)
    values = ChartDataValues.new(chart_manager.run_chart(chart_config, @chart_type), @chart_type).process

    [values]
  end

  def has_chart_data?
    ! data.first.series_data.nil?
  rescue EnergySparksNotEnoughDataException, EnergySparksNoMeterDataAvailableForFuelType, EnergySparksMissingPeriodForSpecifiedPeriodChart
    false
  rescue => e
    Rails.logger.error "Chart generation failed unexpectedly for #{chart_type} and #{@school.name} - #{e.message}"
    Rollbar.error(e)
    false
  end

private

  def customised_chart_config(chart_manager)
    return teachers_landing_page_gas_simple_config if @chart_type == :teachers_landing_page_gas_simple

    chart_config = chart_manager.get_chart_config(@chart_type)
    if chart_config.key?(:yaxis_units) && chart_config[:yaxis_units] == :kwh
      chart_config[:yaxis_units] = @custom_chart_config[:y_axis_units]
      chart_config[:yaxis_units] = :£ if @custom_chart_config[:y_axis_units] == :gb_pounds
    end

    if @custom_chart_config[:mpan_mprn].present?
      chart_config[:meter_definition] = @custom_chart_config[:mpan_mprn].to_i
    end
    chart_config
  end

  # TODO have this chart configuration set up correctly in analytics
  def teachers_landing_page_gas_simple_config
   {
      name:             'Comparison of last 2 weeks gas consumption',
      chart1_type:      :column,
      series_breakdown: :none,
      x_axis_reformat:  { date: '%A' },
      timescale:        [{ workweek: 0 }, { workweek: -1 }],
      x_axis:           :day,
      meter_definition: :allheat,
      yaxis_units:      :£,
      yaxis_scaling:    :none,
    }
  end
end
