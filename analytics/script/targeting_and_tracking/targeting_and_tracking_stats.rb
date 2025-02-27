
# targeting and tracking covid/shortage of data stats for keeping track of progress
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/targetting stats' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def covid_stats(schools)
  stats = {}
  schools.each do |school|
    puts "Analysing #{school.name}"
    %i[electricity gas storage_heater].each do |fuel_type|
      meter = school.aggregate_meter(fuel_type)
      if meter.nil?
        stats["No #{fuel_type} meter"] ||= []
        stats["No #{fuel_type} meter"].push(school.name)
      else
        if fuel_type == :electricity
          season = Covid3rdLockdownElectricityCorrection.new(meter, school.holidays)
          begin
            rule = season.enough_data? ? season.adjusted_amr_data[:rule] : 'not enough data'
          rescue Covid3rdLockdownElectricityCorrection::Unexpected3rdLockdownCOVIDAdjustment => e
            rule = e
          end
          stats[rule] ||= []
          stats[rule].push(school.name)
        end

        enough_data = TargetMeter.enough_amr_data_to_set_target?(meter)
        stats["enough #{fuel_type} amr data"] ||= [] if enough_data
        stats["not enough #{fuel_type} amr data"] ||= [] unless enough_data
        stats[enough_data ? "enough #{fuel_type} amr data" : "not enough #{fuel_type} amr data"].push(school.name)

        if meter.target_set?
          target_set = "target already set #{fuel_type}"
          stats[target_set] ||= []
          stats[target_set].push(school.name)
        end
      end
    end
  end
  stats
end

def print_stats(stats)
  stats.each do |type, school_names|
    puts type
    school_names.each_slice(6) do |names|
      row = names.map{ |ns| ns[0..15].ljust(16) }.join(' | ')
      puts "    #{row}"
    end
  end
end

def school_factory
  $SCHOOL_FACTORY ||= SchoolFactory.new
end

school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

schools = school_names.map do |school_name|
  school_factory.load_or_use_cached_meter_collection(:name, school_name, source_db)
end

stats = covid_stats(schools)

print_stats(stats)
