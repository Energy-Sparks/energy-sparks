class ChartData
  def initialize(aggregated_school, chart_type, show_benchmark_figures, y_axis_units = :kwh)
    @aggregated_school = aggregated_school
    @chart_type = chart_type
    @y_axis_units = y_axis_units
    @show_benchmark_figures = show_benchmark_figures
  end

  def data
    chart_manager = ChartManager.new(@aggregated_school, @show_benchmark_figures)
    chart_config = customised_chart_config(chart_manager)

    values = ChartDataValues.new(chart_manager.run_chart(chart_config, @chart_type), @chart_type).process

    [values]
  end

private

  # JJ This should be handled in the analytics code
  def customised_chart_config(chart_manager)
    chart_config = chart_manager.resolve_chart_inheritance(ChartManager::STANDARD_CHART_CONFIGURATION[@chart_type])
    if chart_config.key?(:yaxis_units) && chart_config[:yaxis_units] == :kwh
      chart_config[:yaxis_units] = @y_axis_units
      chart_config[:yaxis_units] = :£ if @y_axis_units == :gb_pounds
    end
    chart_config
  end
end
