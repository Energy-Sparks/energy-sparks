require 'dashboard'

class Schools::AnalysisController < ApplicationController
  include SchoolAggregation

  skip_before_action :authenticate_user!
  before_action :set_school
  before_action :set_nav
  before_action :set_y_axis_options

  Y_AXIS_UNIT_OPTIONS = {
    pounds: 'energy cost in pounds',
    kwh: 'energy used in kilowatt-hours',
    co2: 'carbon dioxide in kilograms produced generating the energy used',
    library_books: 'number of library books you could buy with energy cost'
  }.freeze

  def set_y_axis_options
    @y_axis_options = Y_AXIS_UNIT_OPTIONS
    @default_y_axis_option = :kwh
  end

  def set_nav
    @dashboard_set = @school.fuel_types_for_analysis
    pages = DashboardConfiguration::DASHBOARD_FUEL_TYPES[@dashboard_set]
    @nav_array = pages.map do |page|
      { name: DashboardConfiguration::DASHBOARD_PAGE_GROUPS[page][:name], path: "#{page}_path" }
    end
  end

  def analysis
    # Redirect to correct dashboard
    redirect_to action: DashboardConfiguration::DASHBOARD_FUEL_TYPES[@dashboard_set][0], school_id: @school.slug
  end

  def main_dashboard_electric
    render_generic_chart_template
  end

  def main_dashboard_gas
    render_generic_chart_template
  end

  def electricity_detail
    render_generic_chart_template
  end

  def main_dashboard_electric_and_gas
    render_generic_chart_template
  end

  def gas_detail
    render_generic_chart_template
  end

  def boiler_control
    render_generic_chart_template
  end

  def test
    render_generic_chart_template
  end

private

  def render_generic_chart_template
    @y_axis_units = if params[:y_axis_unit] && Y_AXIS_UNIT_OPTIONS.key?(params[:y_axis_unit].to_sym)
                      params[:y_axis_unit].to_sym
                    else
                      @default_y_axis_option
                    end

    if @school.fuel_types_for_analysis == :none
      redirect_to school_path(@school), notice: "Analysis is currently unavailable due to a lack of validated meter readings"
    else
      @title = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[action_name.to_sym][:name]
      @charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[action_name.to_sym][:charts]

      @number_of_charts = @charts.size

      # Get this loaded and warm the cache before starting the chart rendering
      aggregate_school(@school)
      render :generic_chart_template
    end
  end

  def set_school
    @school = School.find_by_slug(params[:school_id])
  end
end
