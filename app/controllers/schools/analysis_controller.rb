require 'dashboard'

class Schools::AnalysisController < ApplicationController
  before_action :set_school

  include SchoolAggregation
  include Measurements

  skip_before_action :authenticate_user!
  before_action :build_aggregate_school, except: [:analysis]
  before_action :set_nav
  before_action :set_measurement_options

  def analysis
    if @school.analysis?
      # Redirect to correct dashboard
      redirect_to action: pages.keys.first, school_id: @school.slug
    end
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

  def storage_heaters
    render_generic_chart_template
  end

  def carbon_emissions
    render_generic_chart_template
  end

  def solar_pv
    render_generic_chart_template
  end

private

  def build_aggregate_school
    # use for heat model fitting tabs
    @aggregate_school = aggregate_school
  end

  def set_nav
    @nav_array = pages.map do |page, config|
      { name: config[:name], path: "#{page}_path" }
    end
  end

  def pages
    analyis_pages = @school.configuration.analysis_charts_as_symbols
    analyis_pages.reject {|page| page == :carbon_emissions && cannot?(:analyse, :carbon_emissions)}
  end

  def render_generic_chart_template(extra_chart_config = {})
    @measurement = measurement_unit(params[:measurement])

    @chart_config = { y_axis_units: @measurement }.merge(extra_chart_config)

    @title = title_and_chart_configuration[:name]
    @charts = title_and_chart_configuration[:charts]

    render :generic_chart_template
  end

  def title_and_chart_configuration
    if action_name.to_sym == :test || action_name.to_sym == :heating_model_fitting
      DashboardConfiguration::DASHBOARD_PAGE_GROUPS[action_name.to_sym]
    else
      @school.configuration.analysis_charts_as_symbols[action_name.to_sym]
    end
  end

  def set_school
    @school = School.friendly.find(params[:school_id])
  end
end
