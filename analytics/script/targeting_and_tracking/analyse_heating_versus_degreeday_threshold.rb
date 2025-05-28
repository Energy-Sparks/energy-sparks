# analyses when the heating gets turned on/off
# by analysing the percent of days the heating is on above
# a degree day base temperature
# to get an idea at what degree days base heating should be turned on/off on average
# for determining whether a school should have had its heating on or off
# for targeting and tracking temperature compensation
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/degree day analysis versus heating on ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def calc_heating_model(meter, period)
  meter.heating_model(period)
rescue
  nil
end

def analyse_degree_days_versus_heating_on_for_degree_day_base(school, heating_model, start_date, end_date, degree_day_base_temperature)
  temperatures = school.temperatures

  days_heating_on_when_cold = 0
  days_heating_on_when_warm = 0
  days_of_degree_day_days = 0
  days_of_non_degree_day_days = 0

  (start_date..end_date).each do |date|
    next unless school.holidays.day_type(date) == :schoolday

    if school.temperatures.degree_days(date, degree_day_base_temperature) > 0.0
      days_of_degree_day_days += 1
      days_heating_on_when_cold += 1 if heating_model.heating_on?(date)
    else
      days_of_non_degree_day_days += 1
      days_heating_on_when_warm += 1 unless heating_model.heating_on?(date)
    end
  end

  {
    days_heating_on_when_cold:      days_heating_on_when_cold,
    days_heating_on_when_warm:      days_heating_on_when_warm,
    heating_on_when_warm_percent:   days_heating_on_when_warm.to_f / (days_heating_on_when_warm + days_heating_on_when_cold),
    days_of_degree_day_days:        days_of_degree_day_days,
    days_of_non_degree_day_days:    days_of_non_degree_day_days,
  }
end

def difference_from_threshold(degree_day_base_temperature, school, meter, threshold)
  start_date = [meter.amr_data.end_date - 365, meter.amr_data.start_date].max
  end_date = meter.amr_data.end_date
  period = SchoolDatePeriod.new(:analysis, 'Up to a year', start_date, end_date)
  heating_model = calc_heating_model(meter, period)

  return Float::NAN if heating_model.nil?

  results = analyse_degree_days_versus_heating_on_for_degree_day_base(school, heating_model, start_date, end_date, degree_day_base_temperature)

  (threshold -  results[:heating_on_when_warm_percent]).magnitude
end

def degree_day_threshold(school, meter, threshold)
  optimum = Minimiser.minimize(5.0, 20.0) {|dd| difference_from_threshold(dd, school, meter, threshold) }
  optimum.x_minimum
end

def save_csv(data_by_school)
  filename = "./Results/degreeday base temperature - heating on.csv"
  puts "Saving results to #{filename}"
  CSV.open(filename, 'w') do |csv|
    csv << ['school', 'base temperature (gas)', 'base temperature (storage heater)']
    data_by_school.each do |school_name, degree_day_base_temperature|
      csv << [school_name, degree_day_base_temperature[:gas], degree_day_base_temperature[:storage_heater]]
    end
  end
end

school_name_pattern_match = ['*']

HEATING_ON_PERCENT_ABOVE_WARM_TEMPERATURE_PERCENT = 0.15

source_db = :unvalidated_meter_data

today = Date.new(Date.today.year, 7, 15) # roughly mid summer from temperature perspective

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

data_by_school = {}

school_names.each do |school_name|
  school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)

  %i[gas storage_heater].each do |fuel_type|
    meter = school.aggregate_meter(fuel_type)
    next if meter.nil?

    data_by_school[school_name] ||= {}

    data_by_school[school_name][fuel_type] = degree_day_threshold(school, meter, HEATING_ON_PERCENT_ABOVE_WARM_TEMPERATURE_PERCENT)
  end
end

ap data_by_school

save_csv(data_by_school)
