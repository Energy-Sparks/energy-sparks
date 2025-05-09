# calculate some background information on ventilation
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/default profile calculation ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def school_factory
  $SCHOOL_FACTORY ||= SchoolFactory.new
end

def save_csv(results)
  filename = './Results/average profiles.csv'
  puts "Saving results to #{filename}"

  CSV.open(filename, 'w') do |csv|
    csv << ['school name', 'model type', (0..47).to_a].flatten
    results.each do |school_name, data|
      data.each do |type, x48|
        csv << [school_name, type, x48].flatten
      end
    end
  end
end

def calculate_average_school(results)
  model_types = results.values.map { |mtypes| mtypes.keys }.flatten.uniq

  by_type = {}
  results.each do |school_name, model_type_data|
    model_type_data.each do |type, x48|
      by_type[type] ||= []
      by_type[type].push(x48)
    end
  end

  normalised_by_model = by_type.transform_values do |days_kwh_x48|
    average_by_model = AMRData.fast_average_multiple_x48(days_kwh_x48)
    AMRData.fast_multiply_x48_x_scalar(average_by_model, 1 / average_by_model.sum)
  end
end

def calculate_average_profile_heating(school, heat_meter)
  puts "Calculating heating meter data for #{school.name}"

  unless heat_meter.amr_data.days > 364
    puts "Unable to calculatemodel as only #{heat_meter.amr_data.days} of data"
    return
  end

  end_date = heat_meter.amr_data.end_date
  start_date = [end_date - 364, heat_meter.amr_data.start_date].max

  model = heating_model(heat_meter, start_date, end_date)

  model_profiles = {}
  (start_date..end_date).each do |date|
    model_type = model.model_type?(date)
    model_profiles[model_type] ||= []
    model_profiles[model_type].push(heat_meter.amr_data.days_kwh_x48(date))
  end

  normalised_by_model = model_profiles.transform_values do |days_kwh_x48|
    average_by_model = AMRData.fast_average_multiple_x48(days_kwh_x48)
    AMRData.fast_multiply_x48_x_scalar(average_by_model, 1 / average_by_model.sum)
  end

  normalised_by_model
end

def calculate_average_profile_electricity(school, electric_meter)
  puts "Calculating electricity meter data for #{school.name}"

  unless electric_meter.amr_data.days > 364
    puts "Unable to calculate as only #{electric_meter.amr_data.days} of data"
    return
  end

  profiles = {}
  ((electric_meter.amr_data.end_date - 364)..electric_meter.amr_data.end_date).each do |date|
    type = school.holidays.day_type(date)
    profiles[type] ||= []
    profiles[type].push(electric_meter.amr_data.days_kwh_x48(date))
  end

  normalised = profiles.transform_values do |days_kwh_x48|
    average_by_profile = AMRData.fast_average_multiple_x48(days_kwh_x48)
    AMRData.fast_multiply_x48_x_scalar(average_by_profile, 1 / average_by_profile.sum)
  end

  normalised
end

def heating_model(heat_meter, start_date, end_date)
  last_year = SchoolDatePeriod.new(:year_to_date, 'profile calcs', start_date, end_date)
  heat_meter.heating_model(last_year)
end

def calculate_profiles(school)
  data = {}
  %i[electricity gas skip_storage_heater].each do |fuel_type|
    meter = school.aggregate_meter(fuel_type)
    next if meter.nil?

    case fuel_type
    when :electricity
      res = calculate_average_profile_electricity(school, meter)
      next if res.nil?
      data.merge!(res)
    when :gas, :storage_heater
      res = calculate_average_profile_heating(school, meter)
      next if res.nil?
      data.merge!(res)
    end
  end
  data
end


school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data

results = {}

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

schools = school_names.map do |school_name|
  school = school_factory.load_or_use_cached_meter_collection(:name, school_name, source_db)

  results[school.name] = calculate_profiles(school)

rescue => e
  puts e.message
  puts e.backtrace
end

results['Average School'] = calculate_average_school(results)

save_csv(results)
