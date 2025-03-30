require 'require_all'
require_relative '../lib/dashboard.rb'
require_rel '../test_support'

script = {
  logger1:                  { name: TestDirectory.instance.log_directory + "/datafeeds %{time}.log", format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
  # ruby_profiler:            true,
  schools:                  ['White.*'], # ['Round.*'],
  source:                   :analytics_db,
  # source:                   :aggregated_meter_collection,
  logger2:                  { name: "./log/pupil dashboard %{school_name} %{time}.log", format: "%{datetime} %{severity.ljust(5, ' ')}: %{msg}\n" },
  pupil_dashboard:          {
                              control: {
                                root:    :adult_analysis_page, # :pupil_analysis_page,
                                chart_manipulation: %i[drilldown timeshift],
                                display_average_calculation_rate: true,
                                report_failed_charts:   :summary, # :detailed
                                compare_results:        [ :summary, :report_differing_charts, :report_differences ] # :quick_comparison,
                              }
                            }
}

RunTests.new(script).run