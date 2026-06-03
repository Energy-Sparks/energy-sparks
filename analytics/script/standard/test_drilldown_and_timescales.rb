require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

ENV['ENERGYSPARKSMETERCOLLECTIONDIRECTORY'] +=  '\\Working'

script = {
  logger1:                  { name: TestDirectory.instance.log_directory + "/datafeeds %{time}.log", format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
  # ruby_profiler:            true,
  schools:                  ['bathamp*'], # ['Round.*'],
  source:                   :unvalidated_meter_data,
  logger2:                  { name: "./log/reports %{school_name} %{time}.log", format: "%{datetime} %{severity.ljust(5, ' ')}: %{msg}\n" },
  drilldown:                { chart_name: :baseload_versus_benchmarks },
  timescales:               { chart_name: :management_dashboard_group_by_week_electricity }
  # timescale_and_drilldown:    true
}

RunTests.new(script).run
