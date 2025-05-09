require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/regional degreeday analysis ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def calculate_stats(school)
  return {} if school.aggregated_heat_meters.nil?

  meter = school.aggregated_heat_meters
  start_date  = meter.amr_data.start_date
  end_date    = meter.amr_data.end_date

  return {} if end_date - start_date < 365

  begin
    start_date = end_date - 365

    split_hw_heating = HotWaterHeatingSplitter.new(school)

    detail = split_hw_heating.split_heat_and_hot_water(start_date, end_date, meter: meter)

    heating_degree_days = detail[:heating_day_dates].map { |date| school.temperatures.degree_days(date, 15.5) }.sum

    split = split_hw_heating.aggregate_heating_hot_water_split(start_date, end_date, meter: meter)
  rescue EnergySparksNotEnoughDataException => e
    split = {}
    heating_degree_days = nil
  end

  {
    name:                 school.name,
    latitude:             school.latitude,
    longitude:            school.longitude,
    floor_area:           school.floor_area,
    pupils:               school.number_of_pupils,
    type:                 school.school_type,
    degree_days:          school.temperatures.degree_days_in_date_range(start_date, end_date, 15.5),
    heating_degree_days:  heating_degree_days
  }.merge(split)
end

def save_to_csv(results)
  unique_fields = {}
  results.each { |school_results| unique_fields.merge!(school_results) }
  fields = unique_fields.keys

  dir = TestDirectory.instance.results_directory('modelling')
  filename = File.join(dir, 'heat_hw_split.csv')
  puts "Saving to #{filename}"

  CSV.open(filename, 'w') do |csv|
    csv << fields
    results.each do |school_results|
      csv << fields.map { |f| school_results[f] }
    end
  end
end

school_name_pattern_match = ['*']

source_db = :unvalidated_meter_data

results = []

school_names = SchoolFactory.instance.school_file_list(source_db, school_name_pattern_match)

school_names.each do |school_name|
  school = SchoolFactory.instance.load_school(source_db, school_name, cache: true)

  results.push(calculate_stats(school))
end

save_to_csv(results)

exit
