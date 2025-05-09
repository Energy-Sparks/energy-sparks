require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new(File.join('log', "economic costs #{DateTime.now.strftime('%Y-%m-%d %H%M%S')}.log"))
  logger.level = :debug
end

charts = {
  electricity: %i[
    test_economic_costs_electric_by_week_unlimited_£
    test_economic_costs_electric_by_week_unlimited_co2
    test_economic_costs_electric_by_week_unlimited_kwh
    test_economic_costs_electric_by_week_unlimited_kwh_meter_breakdown
    electricity_cost_1_year_accounting_breakdown
    test_economic_costs_electric_by_datetime_year_£
  ],
  gas: %i[
    test_economic_costs_gas_by_week_unlimited_£
    test_economic_costs_gas_by_week_unlimited_co2
    test_economic_costs_gas_by_week_unlimited_kwh
    test_economic_costs_gas_by_week_unlimited_kwh_meter_breakdown
    gas_cost_1_year_accounting_breakdown
  ]
}

control = {
  save_to_excel:  true,

  compare_results: [
    :summary,
    :report_differences,
    :report_differing_charts
  ]
}

overrides = {
  schools:          ['king-james*'],
  cache_school:     false,
  economic_costs:   { charts: charts, control: control }
}

script = RunAnalyticsTest.default_config.deep_merge(overrides)

begin
  RunTests.new(script).run
rescue => e
  puts e.message
  puts e.backtrace
end
