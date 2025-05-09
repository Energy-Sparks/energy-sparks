# test report manager
require 'ruby-prof'
require 'benchmark/memory'
require 'require_all'
require_relative '../lib/dashboard.rb'
require_rel '../test_support'
require './script/report_config_support.rb'

script = {
  logger1:                  { name: TestDirectory.instance.log_directory + "/pv %{time}.log", format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
  # ruby_profiler:            true,
  schools:                  [
                              'long*',
                              'bishop-sutton*',
                              'paulton*',
                              'ralph*',
                              'st-martin-s-garden*',
                              'all-saints*',
                              'little-horstead*',
                              'robsack*',
                              'milton-of-leys*',
                              'caldecott*',
                              'windmill*',
                              'ballifield*',
                              'hugh-sexey*',
                              'portsmouth-high*'
                            ],
  source:                   :unvalidated_meter_data,
  logger2:                  { name: "./log/reports %{school_name} %{time}.log", format: "%{datetime} %{severity.ljust(5, ' ')}: %{msg}\n" },
  reports:                  {
                              charts: [
                                adhoc_worksheet: { name: 'Test', charts: %i[
                                  solar_pv_group_by_month
                                  solar_pv_last_7_days_by_submeter
                                  group_by_week_electricity
                                  ]},
                              ],
                              control: {
                                display_average_calculation_rate: true,
                                report_failed_charts:   :summary,
                                compare_results:        [
                                  { comparison_directory: ENV['ANALYTICSTESTRESULTDIR'] + '\SolarPVAggregation\Base' },
                                  { output_directory:     ENV['ANALYTICSTESTRESULTDIR'] + '\SolarPVAggregation\New' },
                                  :summary,
                                  :quick_comparison,
                                ]
                              }
                            },
}

RunTests.new(script).run
