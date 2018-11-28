require 'dashboard'

class Schools::AnalysisController < ApplicationController
  include SchoolAggregation

  skip_before_action :authenticate_user!
  before_action :set_school
  before_action :set_nav

  def set_nav
    @dashboard_set = @school.fuel_types
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

  def chart
    chart_type = params[:chart_type].to_sym

    @charts = [chart_type]
    @title = chart_type.to_s.humanize
    actual_chart_render(@charts)
  end

private

  def render_generic_chart_template
    @title = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[action_name.to_sym][:name]
    @charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[action_name.to_sym][:charts]
    actual_chart_render(@charts)
  end

  def actual_chart_render(charts)
    @number_of_charts = charts.size

    respond_to do |format|
      format.html do
        aggregate_school(@school)
        render :generic_chart_template
      end
      format.json do
        @output = sort_these_charts(charts)
        render :chart_data
      end
    end
  end

  def sort_these_charts(array_of_chart_types_as_symbols)
    this_aggregate_school = aggregate_school(@school)

    @cache_debug_info = this_aggregate_school.electricity_meters.map do |meter|
      "Mpan: #{meter.mpan_mprn} Last Reading from : #{meter.last_read}\n"
    end

    chart_manager = ChartManager.new(this_aggregate_school, current_user.try(:admin?))

    array_of_chart_types_as_symbols.map do |chart_type|
      { chart_type: chart_type, data: chart_manager.run_standard_chart(chart_type) }
    end
  end

  def set_school
    @school = School.find_by_slug(params[:school_id])
  end
end
