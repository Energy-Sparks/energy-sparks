require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/systemslink ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end


def monthly_meter_comparison_table(meter, start_date, end_date)
  puts "Doing #{meter.mpxn}"
  amr_data = meter.amr_data
  start_date = [start_date, amr_data.start_date].max
  end_date = [end_date, amr_data.end_date].min
  aggregate = {}
  (start_date..amr_data.end_date).each do |date|
    month = date.strftime('%Y %m')
    aggregate[month] ||= 0.0
    days_data = amr_data.one_day_kwh(date)
    aggregate[month]  += days_data
  end
  aggregate
end

def save_csv(mpxn, readings)
  CSV.open('Results\systems_link_meter_readings.csv', 'a') do |csv|
    readings.each do |month, kwh|
      csv << [mpxn, month, kwh]
    end
  end
end


start_date = Date.new(2019, 4, 1)
end_date    = Date.new(2021,3,31)

# replicate systems link monthly comparison table
school_name_pattern_match = ['durham-st*'] # 'n3rgy*',
source_db = :unvalidated_meter_data
school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

school_names.each do |school_name|
  school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)
  school.real_meters.each do |meter|
    readings = monthly_meter_comparison_table(meter, start_date, end_date)
    save_csv(meter.mpxn, readings)
  end
end
