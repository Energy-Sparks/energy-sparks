require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/systemslink ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end


def monthly_meter_comparison_table(meter)
  return [] if meter.fuel_type != :electricity
  missing_dates = []
  amr_data = meter.amr_data
  (amr_data.start_date..amr_data.end_date).each do |date|
    missing_dates.push(date) if amr_data.one_day_kwh(date) == 0.0
  end
  pack_dates(missing_dates)
end

def pack_dates(dates)
  dates.slice_when do |curr, prev|
    curr + 1 != prev
  end.map{|a| a[0]..a[-1]}
end

def present_missing(school, meter, missing)
  puts "School: #{school.name}"
  puts "  Meter: #{meter.mpxn} #{meter.name} #{meter.fuel_type}"
  missing.each do |missing_range|
    days = (missing_range.last - missing_range.first + 1).to_i
    puts "    Zero: #{missing_range.first} to #{missing_range.last} x#{days}"
  end
end

# replicate systems link monthly comparison table
school_name_pattern_match = ['*'] # 'n3rgy*',
source_db = :unvalidated_meter_data
school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

school_names.each do |school_name|
  school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)
  school.real_meters.each do |meter|
    missing = monthly_meter_comparison_table(meter)
    present_missing(school, meter, missing) unless missing.empty?
  end
end
