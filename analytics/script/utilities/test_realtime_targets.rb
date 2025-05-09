require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/realtime-targets ' + Time.now.strftime('%H %M') + '.log')
  @logger.level = :debug
end

ENV['ENERGYSPARKSMETERCOLLECTIONDIRECTORY'] +=  '\\Community'

school_name_pattern_match = ['king-j*']
source_db = :unvalidated_meter_data

school_name = RunTests.resolve_school_list(source_db, school_name_pattern_match).first
school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)

service = PowerConsumptionService.create_service(school, school.aggregated_electricity_meters, Date.today)

puts service.perform(Time.now)
