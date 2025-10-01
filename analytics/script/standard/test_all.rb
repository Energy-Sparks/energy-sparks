# test report manager
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'
require './script/report_config_support.rb'

module Logging
  @logger = Logger.new(File.join('log', 'logs.log'))
  logger.level = :error
end

run_date = Date.new(2022, 4, 23)

overrides = {
  schools:      ['*'],
  cache_school: false
}

benchmark_overrides = overrides.merge(
  {
    calculate_and_save_variables: true,
    asof_date:     run_date,
    run_content: { asof_date: run_date }
  }
)

alert_overrides = overrides.merge(alerts:   { alerts: nil, control: { asof_date: run_date} })

chart_control = {
  save_to_excel:  true,

  compare_results: [
    :summary,
    :report_differences,
    :report_differing_charts
  ]
}

chart_overrides = {
  charts:   { charts: RunCharts.standard_charts_for_school, control: chart_control }
}.merge(overrides)

scripts = {
  'Expert Analysis Pages'    => RunAdultDashboard.default_config.deep_merge(overrides),
  'Benchmarks'               => RunBenchmarks.default_config.deep_merge(benchmark_overrides),
  'Alerts'                   => RunAlerts.default_config.deep_merge(alert_overrides),
  'Equivalences'             => RunEquivalences.default_config.deep_merge(overrides),
  'Charts'                   => RunCharts.default_config.deep_merge(chart_overrides)
}

scripts.each do |name, script|
  puts "*" * 200
  STDERR.puts "Running: #{name}"
  puts "*" * 200
  RunTests.new(script).run
end
