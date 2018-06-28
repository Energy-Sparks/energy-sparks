require 'dashboard'

class Schools::ChartDataController < ApplicationController
  before_action :authorise_school
  before_action :set_nav

  def set_nav
    @dashboard_set = @school.fuel_types
    pages = DashboardConfiguration::DASHBOARD_FUEL_TYPES[@dashboard_set]
    @nav_array = pages.map do |page|
      { name: DashboardConfiguration::DASHBOARD_PAGE_GROUPS[page][:name], path: "#{page}_path" }
    end
  end

  def dashboard
    redirect_to action: DashboardConfiguration::DASHBOARD_FUEL_TYPES[@dashboard_set][0], school_id: @school.slug
    # Redirect to correct dashboard
  end

  def main_dashboard_electric
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

  def simulator
    render_generic_chart_template
  end

  def chart
    chart_type = params[:chart_type]
    chart_type = chart_type.to_sym if chart_type.instance_of? String
    @charts = [chart_type]
    @title = chart_type.to_s.humanize
    actual_chart_render(@charts)
  end

  def render_generic_chart_template
    @title = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[action_name.to_sym][:name]
    @charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[action_name.to_sym][:charts]
    actual_chart_render(@charts)
  end

  def actual_chart_render(charts)
    @number_of_charts = charts.size
    @output = sort_these_charts(charts)

    respond_to do |format|
      format.html { render :generic_chart_template }
      format.json { render :chart_data }
    end
  end

  def excel
    reportmanager = ReportManager.new(aggregate_school)
    worksheets = reportmanager.run_reports(reportmanager.standard_reports)

    excel = ExcelCharts.new(Rails.public_path.join("#{aggregate_school.name}-charts-test.xlsx"))

    worksheets.each do |worksheet_name, charts|
      excel.add_charts(worksheet_name, charts)
    end
    excel.close
  end

  def holidays
    render json: aggregate_school.holidays
  end

  def solar_irradiance
    render json: aggregate_school.solar_insolance
  end

  def solar_pv
    render json: aggregate_school.solar_pv
  end

  def electricity_meters
    render json: aggregate_school.electricity_meters
  end

  def gas_meters
    render json: aggregate_school.heat_meters
  end

  def aggregated_electricity_meters
    render json: aggregate_school.aggregated_electricity_meters.amr_data
  end

  def aggregated_gas_meters
    render json: aggregate_school.aggregated_heat_meters.amr_data
  end

private

  def sort_these_charts(array_of_chart_types_as_symbols)
    chart_manager = ChartManager.new(aggregate_school)

    array_of_chart_types_as_symbols.map do |chart_type|
      { chart_type: chart_type, data: chart_manager.run_standard_chart(chart_type) }
    end
  end

  def authorise_school
    @school = School.find_by_slug(params[:school_id])
    authorize! :show, @school
  end

  def aggregate_school
    meter_collection = MeterCollection.new(@school)
    AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
  end
end
