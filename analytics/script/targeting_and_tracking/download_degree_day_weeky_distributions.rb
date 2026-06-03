# writes actual kWh and degree day distributions to csv file for comparison
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/school weekly degree day distributions ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def week_of_year(date)
  jan_1 = Date.new(date.year, 1, 1)
  # use Saturday for gas, as weekend thermal mass will have an influence
  saturday_of_week1 = jan_1 - jan_1.wday - 1
  week = ((date - saturday_of_week1) / 7).to_i
end

def weekly_school_day_kwhs(school, fuel_type, start_date, end_date)
  meter = school.aggregate_meter(fuel_type)
  return {} if meter.nil? || meter.amr_data.start_date > start_date || meter.amr_data.end_date < end_date

  school_week_kwh       = Array.new(53, 0.0)
  degreedays            = Array.new(53, 0.0)
  school_week_day_count = Array.new(53, 0.0)

  (start_date..end_date).each do |date|
    next if school.holidays.day_type(date) != :schoolday

    week = week_of_year(date)

    school_week_kwh[week]       += meter.amr_data.one_day_kwh(date)
    degreedays[week]            += school.temperatures.degree_days(date, 15.5)
    school_week_day_count[week] += 1.0
  end

  average_school_day_kwh_by_week = school_week_kwh.map.with_index do |kwh, week|
    if school_week_day_count[week] > 2
      kwh / school_week_day_count[week]
    else
      Float::NAN
    end
  end

  average_school_day_degreedays_by_week = degreedays.map.with_index do |dd, week|
    if school_week_day_count[week] > 2
      dd / school_week_day_count[week]
    else
      Float::NAN
    end
  end

  total_dd  = average_school_day_degreedays_by_week.map{ |v| v.nan? ? 0.0 : v }.sum
  total_kwh = average_school_day_kwh_by_week.map{ |v| v.nan? ? 0.0 : v }.sum

  school_day_dd_by_week_normalised_to_1 = average_school_day_degreedays_by_week.map { |dd| dd / total_dd }
  school_day_kwh_by_week_normalised_to_1 = average_school_day_kwh_by_week.map { |kwh| kwh / total_kwh }
  [school_day_kwh_by_week_normalised_to_1, school_day_dd_by_week_normalised_to_1]
end

def sub_nil_nan(arr)
  arr.map { |v| v.nan? ? nil : v }
end

def save_csv(data)
  filename = "./Results/targeting_and_tracking_synthetic_distributions gas schools.csv"
  puts "Saving results to #{filename}"
  CSV.open(filename, 'w') do |csv|
    data.each do |school_name, week_avg_kwhs|
      csv << [school_name, sub_nil_nan(week_avg_kwhs)].flatten
    end
  end
end

regional_school_examples = ['bathampton', 'saunders', 'portsm*', 'peven*', 'long*', 'abbey*', 'durham*']

school_name_pattern_match = regional_school_examples

source_db = :unvalidated_meter_data

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

ap school_names
data = {}
start_date = Date.new(2020, 7, 1)
end_date = Date.new(2021, 6, 30)

school_names.each do |school_name|
  school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)

  school_data, degreedays = weekly_school_day_kwhs(school, :gas, start_date, end_date)
  next if school_data.empty?
  data[school_name] = school_data
  data["#{school_name} - best fit dd"] = degreedays
end

save_csv(data)

