# calculate some background information on ventilation
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/ventilation ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def school_factory
  $SCHOOL_FACTORY ||= SchoolFactory.new
end

def save_csv(results)
  filename = './Results/ventilation analysis.csv'
  puts "Saving results to #{filename}"
  CSV.open(filename, 'w') do |csv|
    csv << ['school name', results.values.first.keys].flatten
    results.each do |school_name, data|
      csv << [school_name, data.values].flatten
    end
  end
end

def controlled_ventilation(ventilation, ventilation_rates)
  ventilation.ventilation_calculations(litres_per_second_per_person: ventilation_rates)
end

def calculate_school_ventilation(school, heat_meter)
  ventilation = BuildingVentilation.new(school, heat_meter)

  results = {}

  ventilation_rates = [5.0, 10.0]

  results = controlled_ventilation(ventilation, ventilation_rates)

  ap results

  results[:impact_of_increased_ventilation_kwh]     = results[:annual_heat_loss_kwh_at_10_litres] - results[:annual_heat_loss_kwh_at_5_litres]
  # NB the _at_10_litres is meaningless as its the current unimpacted? annual kWh, same for all controlled_ventilation() calls
  results[:impact_of_increased_ventilation_percent] = results[:impact_of_increased_ventilation_kwh] / results[:annual_kwh]

  ap results

  results
end

school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data

results = {}

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

schools = school_names.map do |school_name|
  school = school_factory.load_or_use_cached_meter_collection(:name, school_name, source_db)

  if !school.aggregated_heat_meters.nil?
    results[school.name] = calculate_school_ventilation(school, school.aggregated_heat_meters)
  elsif !school.storage_heater_meter.nil?
    results[school.name] = calculate_school_ventilation(school, school.storage_heater_meter)
  end
rescue => e
  puts e.message
  puts e.backtrace
end

ap results

save_csv(results)
