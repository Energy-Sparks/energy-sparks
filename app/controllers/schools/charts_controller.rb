require 'dashboard'

class Schools::ChartsController < ApplicationController
  include SchoolAggregation

  skip_before_action :authenticate_user!
  before_action :set_school

  def show
    chart_type = params[:chart_type].to_sym
    y_axis_units = params[:chart_y_axis_units].to_sym if params[:chart_y_axis_units]

    @charts = [chart_type]
    @title = chart_type.to_s.humanize
    @number_of_charts = 1

    @output = [{ chart_type: chart_type, data: get_chart_data(chart_type, current_user.try(:admin?), y_axis_units) }]
  end

private

  def get_chart_data(chart_type, show_benchmark_figures, y_axis_units = :kwh)
    aggregated_school = aggregate_school(@school)
    chart_manager = ChartManager.new(aggregated_school, show_benchmark_figures)
    chart_config = chart_manager.resolve_chart_inheritance(ChartManager::STANDARD_CHART_CONFIGURATION[chart_type])

    if chart_config.key?(:yaxis_units) && chart_config[:yaxis_units] == :kwh
      chart_config[:yaxis_units] = y_axis_units
      chart_config[:yaxis_units] = :£ if y_axis_units == :pounds
    end

    chart_manager.run_chart(chart_config, chart_type)
  end

  def set_school
    @school = School.find_by_slug(params[:school_id])
  end
end
