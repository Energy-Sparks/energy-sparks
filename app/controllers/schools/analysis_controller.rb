require 'dashboard'

class Schools::AnalysisController < ApplicationController
  include SchoolAggregation

  skip_before_action :authenticate_user!
  before_action :set_school
  before_action :set_nav
  before_action :set_y_axis_options

  Y_AXIS_UNIT_OPTIONS = {
    gb_pounds: 'energy cost in pounds',
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
    @y_axis_units = check_for_y_axis_param_or_cookie

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

  def check_for_y_axis_param_or_cookie
    if params[:measurement] && Y_AXIS_UNIT_OPTIONS.key?(params[:measurement].to_sym)
      # Set cookie

      cookies[:energy_sparks_measurement] = params[:measurement]
      params[:measurement].to_sym
    else
      default_y_axis_option_or_cookie
    end
  end

  def default_y_axis_option_or_cookie
    if cookies[:energy_sparks_measurement]
      cookies[:energy_sparks_measurement].to_sym
    else
      @default_y_axis_option
    end
  end

  def set_school
    @school = School.find_by_slug(params[:school_id])
  end
end
