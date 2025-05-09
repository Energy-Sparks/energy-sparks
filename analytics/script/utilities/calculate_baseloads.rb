require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/baseload calc ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

school_name_pattern_match = ['b*']

school_names = SchoolFactory.instance.school_file_list(:unvalidated_meter_data, school_name_pattern_match)

# preload to tidy up output
school_names.each do |school_name|
  SchoolFactory.instance.load_school(:unvalidated_meter_data, school_name, cache: true)
end

def fmt(num, f = '%0.3f')
  sprintf(f,num)
end

schools = school_names.map do |school_name|
  school = SchoolFactory.instance.load_school(:unvalidated_meter_data, school_name, cache: true)
  meter = school.aggregated_electricity_meters
  next if meter.nil?

  years = (meter.amr_data.days / 365.0).to_i

  for year in 0...years do
    asof_date = meter.amr_data.end_date - year * 365
    start_date = asof_date - 365

    name = sprintf('%-20.20s', school.name)
    analyse = ElectricityBaseloadAnalysis.new(school.aggregated_electricity_meters)

    blended_co2_intensity_kg_per_kwh  = school.aggregated_electricity_meters.amr_data.blended_rate(:kwh, :co2, start_date, asof_date)
    baseload_co2_intensity_kg_per_kwh = analyse.baseload_co2_carbon_intensity_co2_k2_per_kwh(asof_date)
    baseload_co2_1_year_kg            = analyse.one_years_baseload_co2_kg(asof_date)

    diff = (blended_co2_intensity_kg_per_kwh - baseload_co2_intensity_kg_per_kwh) * 1000.0

    puts "#{name}: #{asof_date.year} Blended CO2: #{fmt(blended_co2_intensity_kg_per_kwh)} Baseload CO2 Intensity #{fmt(baseload_co2_intensity_kg_per_kwh)} Baseload CO2 1 year #{baseload_co2_1_year_kg.round(0)} diff #{fmt(diff, '%2.1f')}"
  end
end