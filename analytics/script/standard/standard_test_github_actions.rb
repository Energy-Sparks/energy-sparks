# This is a copy of the standard_tests.rb test script, adapted so we can run it on Github actions without
# error logging and using an anonymised meter reading file.
# It requires a test output folder with a meter collections yaml file with 'acme-academy' in the
# name (e.g. unvalidated-data-acme-academy.yaml). This needs to be stored in a `MeterCollections` folder,
# within your test_ouputs folder at run time, for example:
#
# energy-sparks_analytics
#   - test_ouput
#     - MeterCollections
#       - unvalidated-data-acme-academy.yaml
#
# To run this test you need to set the ANALYTICSTESTDIR environment variable to point to the test output
# directory as described above. e.g.
#
# ANALYTICSTESTDIR=test_output bundle exec ruby script/standard/test_alerts.rb
#

require 'require_all'
require_relative '../../../config/environment'
require_relative '../../lib/dashboard'
require_all './analytics/test_support/'

schools = [
  { name: 'acme-academy*', example_of: 'Github actions test data' }
]

overrides = {
  schools: schools.map{ |sc| sc[:name] },
}

run_date = Date.new(2022, 2, 1)

scripts = [
    { type: RunAdultDashboard },
    { type: RunAlerts,                parameters: { alerts:   { control: { asof_date: run_date } } } },
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
