require 'dashboard'

class Schools::ChartDataController < ApplicationController
  before_action :authorise_school
  before_action :set_nav

  DASHBOARD_PAGE_GROUPS = {
    main_dashboard_electric:          { name:   'Main Dashboard', charts: %i[benchmark_electric] },
    electricity_year:                 { name:   'Electricity Year', charts: %i[benchmark_electric] },
    electricity_longterm:             { name:   'Electricity Analysis long term', charts: %i[daytype_breakdown_electricity group_by_week_electricity electricity_by_day_of_week baseload electricity_by_month_year_0_1 intraday_line_school_days intraday_line_holidays intraday_line_weekends] },
    gas_thermostatic:                 { name:   'Gas Detail (thermostatic)', charts: %i[daytype_breakdown_gas group_by_week_gas gas_by_day_of_week thermostatic cusum] },
    recent_electric:                  { name:   'Electricity Recent', charts: %i[intraday_line_school_days intraday_line_school_days_last5weeks intraday_line_school_days_6months intraday_line_school_last7days baseload_lastyear] },
    main_dashboard_electric_and_gas:  { name:   'Main Dashboard', charts: %i[benchmark daytype_breakdown_electricity daytype_breakdown_gas group_by_week_electricity group_by_week_gas] },
#    main_dashboard_electric_and_gas:  { name:   'Main Dashboard', charts: %i[benchmark] },
    electric_and_gas_year:            { name:   'Electricity & Gas Year', charts: %i[benchmark] },
    recent_electric_and_gas:          { name:   'Recent Electricity & Gas', charts: %i[benchmark] }
  }.freeze

  SCHOOL_REPORT_GROUPS = {
    electric_only: %i[main_dashboard_electric electricity_year electricity_longterm recent_electric],
    electric_and_gas: %i[main_dashboard_electric_and_gas electric_and_gas_year electricity_longterm gas_thermostatic recent_electric],
    electric_and_gas_and_pv: %i[main_dashboard_electric_and_gas electric_and_gas_year electricity_longterm gas_thermostatic recent_electric_and_gas],
    electric_and_gas_and_storage_heater: %i[main_dashboard_electric_and_gas electric_and_gas_year electricity_longterm gas_thermostatic recent_electric_and_gas]
  }.freeze

  SCHOOLS = {
    'Bishop Sutton Primary School'      => :electric_and_gas,
    'Castle Primary School'             => :electric_and_gas,
    'Freshford C of E Primary'          => :electric_and_gas,
    'Marksbury C of E Primary School'   => :electric_only,
    'Paulton Junior School'             => :electric_and_gas,
    'Pensford Primary'                  => :electric_only,
    'Roundhill School'                  => :electric_and_gas,
    'Saltford C of E Primary School'    => :electric_and_gas,
    'St Johns Primary'                  => :electric_and_gas,
    'Stanton Drew Primary School'       => :electric_only,
    'Twerton Infant School'             => :electric_and_gas,
    'Westfield Primary'                 => :electric_and_gas
  }.freeze

  def set_nav
    dashboard_set = SCHOOLS[@school.name.strip]
    pages = SCHOOL_REPORT_GROUPS[dashboard_set]
    @nav_array = pages.map do |page|
      { name: DASHBOARD_PAGE_GROUPS[page][:name], path: "#{page}_path" }
    end
  end

  def dashboard
    dashboard_set = SCHOOLS[@school.name.strip]
    redirect_to action: SCHOOL_REPORT_GROUPS[dashboard_set][0], school_id: @school.slug
    # Redirect to correct dashboard
  end

  def main_dashboard_electric
    render_generic_chart_template
  end

  def electricity_year
    render_generic_chart_template
  end

  def recent_electric
    render_generic_chart_template
  end

  # Main dashboard
  def main_dashboard_electric_and_gas
    render_generic_chart_template
  end

  # Electric and Gas Year
  def electric_and_gas_year
    render_generic_chart_template
  end

  # Electricity Longterm
  def electricity_longterm
    render_generic_chart_template
  end

  # Gas thermostatic 'Gas Detail (thermostatic)'
  def gas_thermostatic
    render_generic_chart_template
  end

  # recent_electric_and_gas
  def recent_electric_and_gas
    render_generic_chart_template
  end

  def render_generic_chart_template
    @title = DASHBOARD_PAGE_GROUPS[action_name.to_sym][:name]
    @charts = DASHBOARD_PAGE_GROUPS[action_name.to_sym][:charts]
    @number_of_charts = @charts.size
    @output = sort_these_charts(@charts)

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
