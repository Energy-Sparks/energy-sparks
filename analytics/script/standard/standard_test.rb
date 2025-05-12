require 'require_all'
require_relative '../../lib/dashboard.rb'
require_all './test_support/'

module Logging
  @logger = Logger.new(File.join('log', 'standard test.log'))
  logger.level = :debug
end

schools = [
  { name: 'cefn-hengoed*',          example_of: 'multiple solar production meters' },
  { name: 'green-lane*',            example_of: 'vanilla primary with electric and gas meters' },
  { name: 'hugh-sexey*',            example_of: 'sheffield simulated solar PV school' },
  { name: 'king-james*',            example_of: 'vanilla secondary with electric and gas meters' },
  { name: 'long-furlong*',          example_of: 'vanilla rbee-lch solar PV school' },
  { name: 'marksbury*',             example_of: 'vanilla storage heater school' },
  { name: 'newcastle-high*senior*', example_of: 'school with many meters' },
  { name: 'pennyland*',             example_of: 'school with multiple storage heater meters' },
  { name: 'ph-school*',             example_of: 'DCC school with differential tariffs' },
]

overrides = {
  schools: schools.map{ |sc| sc[:name] },
}

run_date = Date.new(2022, 8, 5)

benchmark_params = {
  benchmarks: {
    calculate_and_save_variables: true,
    asof_date:     run_date,
    run_content: { asof_date: run_date }
  }
}

scripts = [
    { type: RunAdultDashboard },
    { type: RunAlerts,                parameters: { alerts:   { control: { asof_date: run_date } } } },
    { type: RunBenchmarks,            parameters: benchmark_params},
    { type: RunManagementSummaryTable },
    { type: RunEquivalences }
]

scripts.each do |script_type|
  puts '=' * 100
  puts "Running test type #{script_type[:type]}"

  script = script_type[:type].default_config.deep_merge(overrides)
  script = script.deep_merge(script_type[:parameters]) if script_type.key?(:parameters)

  RunTests.new(script).run
end
