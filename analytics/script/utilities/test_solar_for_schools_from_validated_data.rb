require 'require_all'
require_relative '../lib/dashboard.rb'
require_rel '../test_support'
require './script/report_config_support.rb'
require 'ruby-prof'

profile = false

module Logging
  @logger = Logger.new('log/solar for schools' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

if false
  school_name_pattern_match = ['*ingfish*']
  source_db = :unvalidated_meter_data # :analytics_db

  school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

  school_names.each do |school_name|
    puts "==============================Doing #{school_name} ================================"

    school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)

    school.electricity_meters.each do |meter|
      puts "Got a #{meter.meter_type}"
    end
  end
end

lcc = false
if lcc
  school_name_pattern_match = ['*ong*']
  source_db = :aggregated_meter_collection # :analytics_db
else
  school_name_pattern_match = ['*ingfish*']
  source_db = :unvalidated_meter_data # :analytics_db
end

script = {
  logger1:                  { name: TestDirectory.instance.log_directory + "/datafeeds %{time}.log", format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
  source:                   source_db,
  schools:                  school_name_pattern_match,
  logger2:                  { name: "./log/reports %{school_name} %{time}.log", format: "%{datetime} %{severity.ljust(5, ' ')}: %{msg}\n" },
  reports:                  {
                              charts: [
                                adhoc_worksheet: { name: 'Test', charts: %i[
                                  solar_pv_group_by_month
                                  solar_pv_last_7_days_by_submeter
                                  solar_pv_group_by_month
                                  solar_pv_last_7_days_by_submeter
                                  ]},
                              ],
                              control: {
                                display_average_calculation_rate: true,
                                report_failed_charts:   :summary,
                                no_compare_results:        [
                                  :summary,
                                  :quick_comparison,
                                ]
                              }
                            },
}

RunTests.new(script).run

