require 'dashboard'

class Schools::AnalysisController < ApplicationController
  include SchoolAggregation
  include Measurements

  skip_before_action :authenticate_user!
  before_action :set_school
  before_action :check_fuel_types
  before_action :build_aggregate_school, except: [:analysis]
  before_action :set_nav
  before_action :set_measurement_options

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

  def heating_model_fitting
    render_generic_chart_template(mpan_mprn: params.require(:mpan_mprn))
  end

private

  def check_fuel_types
    if aggregate_school_service(@school).fuel_types_for_analysis == :none
      redirect_to school_path(@school), notice: "Analysis is currently unavailable due to a lack of validated meter readings"
    end
  end

  def build_aggregate_school
    # Get this loaded and warm the cache before starting the chart rendering
    # and use for heat model fitting tabs
    @aggregate_school = aggregate_school(@school)
  end

  def set_nav
    @dashboard_set = aggregate_school_service(@school).fuel_types_for_analysis
    pages = DashboardConfiguration::DASHBOARD_FUEL_TYPES[@dashboard_set]
    @nav_array = pages.map do |page|
      { name: DashboardConfiguration::DASHBOARD_PAGE_GROUPS[page][:name], path: "#{page}_path" }
    end
  end

  def render_generic_chart_template(extra_chart_config = {})
    @measurement = measurement_unit(params[:measurement])

    @chart_config = { y_axis_units: @measurement }.merge(extra_chart_config)

    @title = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[action_name.to_sym][:name]
    @charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[action_name.to_sym][:charts]

    @number_of_charts = @charts.size

    render :generic_chart_template
  end

  def set_school
    @school = School.friendly.find(params[:school_id])
  end
end
