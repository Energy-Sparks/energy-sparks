require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

asof_date = Date.new(2022, 2, 27)
schools = ['*']

RunAlerts.run_heating_on_alert_seasonal_tests(asof_date, schools).each do |scenario|
  puts '=' * 100
  puts "Running scenario: as of #{scenario[:alerts][:control][:asof_date]} at #{scenario[:alerts][:control][:forecast][:temperature]}C"
  script = RunAlerts.default_config.deep_merge(scenario)
  RunTests.new(script).run
end
