# test report manager
# require 'ruby-prof'
require 'benchmark/memory'
require 'require_all'
require_relative '../../lib/dashboard'
require_rel '../../test_support'
require './script/report_config_support'

script = {
  logger1: { name: TestDirectory.instance.log_directory + '/datafeeds %{time}.log',
             format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
  # logger1:                  { name: STDOUT, format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
  # ruby_profiler:            true,
  # dark_sky_temperatures:    nil,
  # grid_carbon_intensity:    nil,
  # sheffield_solar_pv:       nil,
  no_schools: ['st-mart*'], # ['Round.*'],
  no_source: :aggregated_meter_collection,
  # generate_analytics_school_meta_data: true,
  schools: ['st-mart*', 'paul*', 'long*', 'prend*', 'saund*', 'fresh*'],
  schools: ['belv*'], # ['pentrehafod*'],
  no_source: :analytics_db, # : analytics_db :aggregated_meter_collection :unvalidated_meter_data :load_unvalidated_meter_collection,
  source: :unvalidated_meter_data, #  :aggregated_meter_collection,
  logger2: { name: './log/reports %{school_name} %{time}.log',
             format: "%{datetime} %{severity.ljust(5, ' ')}: %{msg}\n" },
  reports: {
    charts: [
      # :dashboard,
      { adhoc_worksheet: { name: 'Test', charts: %i[
        management_dashboard_group_by_week_gas
      ] } }

      # management_dashboard_group_by_week_electricity
      # solar_pv_group_by_month
      # solar_pv_last_7_days_by_submeter
      # group_by_week_electricity_meter_breakdown_one_year

      # solar_pv_last_7_days_by_submeter
      # adhoc_worksheet: { name: 'Test', charts: %i[calendar_picker_electricity_week_example_comparison_chart
      #   calendar_picker_electricity_day_example_comparison_chart] }
      # :dashboard
      # adhoc_worksheet: { name: 'Test', charts: %i[teachers_landing_page_storage_heaters teachers_landing_page_storage_heaters_simple] }
      # pupils_dashboard: :pupil_analysis_page
    ],
    control: {
      display_average_calculation_rate: true,
      report_failed_charts: :summary,
      # :detailed
      compare_results: [
        :summary,
        # :quick_comparison,
        { comparison_directory: ENV.fetch('ANALYTICSTESTRESULTDIR', nil) + '\Charts\Base' },
        { output_directory:     ENV.fetch('ANALYTICSTESTRESULTDIR', nil) + '\Charts\New' },
        :report_differing_charts,
        :report_differences
      ] # :quick_comparison,
    }
  }
}

RunTests.new(script).run
