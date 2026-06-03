# calculations for cibse hot water inefficiency legionella analysis
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/cibse hot water analysis ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def school_factory
  $SCHOOL_FACTORY ||= SchoolFactory.new
end

def column_names(results)
  results.values.map do |school_results|
    school_results.keys
  end.flatten.uniq
end

def save_csv(results)
  filename = "./Results/cibse hot water analysis.csv"
  puts "Saving results to #{filename}"

  cols = column_names(results)

  CSV.open(filename, 'w') do |csv|
    csv << ['school name', cols].flatten
    results.each do |school_name, school_data|
      data = cols.map { |col_name| school_data[col_name] }
      csv << [school_name, data].flatten
    end
  end
end

def day_type(school, date)
  if DateTimeHelper.weekend?(date)
    :weekend  # include weekends in holidays
  elsif school.holidays.holiday?(date)
    :holiday
  else
    :schoolday
  end
end

def daytype_breakdown(school, meter, start_date, end_date)
  totals = { weekend_kwh: 0.0, holiday_kwh: 0.0, schoolday_kwh: 0.0 }

  (start_date..end_date).each do |date|
    day_type = "#{day_type(school, date)}_kwh".to_sym
    totals[day_type] += meter.amr_data.one_day_kwh(date)
  end
  totals
end

def analyse_hot_water(school)
  results = {}
  investment_analysis = AnalyseHeatingAndHotWater::HotWaterInvestmentAnalysis.new(school)

  investment_data = investment_analysis.analyse_annual

  results[:hot_water_efficiency] = investment_data[:existing_gas][:efficiency]

  results
end

def calculate_implied_litres_per_pupil(school, results)
  days = school_days(school)
  useful_hot_water_kwh = results[:average_hot_water_day_kwh] * results[:hot_water_efficiency] * days
  litres = AnalyseHeatingAndHotWater::HotwaterModel.litres_of_hotwater(useful_hot_water_kwh) / days / school.number_of_pupils
  {
    annual_use_hotwater_usage_kwh:                useful_hot_water_kwh,
    implied_daily_per_pupil_litres_of_hot_water:  litres
  }
end

def school_days(school)
  school.holidays.day_type_statistics(Date.today - 365, Date.today)[:schoolday]
end

def analyse_meter(school, meter)

  results = {}

  end_date = meter.amr_data.end_date
  start_date = [meter.amr_data.start_date, end_date - 365].max

  results[:annual_kwh] = meter.amr_data.kwh_date_range(start_date, end_date)

  results.merge!(analyse_hot_water(school))

  results.merge!(daytype_breakdown(school, meter, start_date, end_date))

  splitter = HotWaterHeatingSplitter.new(school)
  results.merge!(splitter.aggregate_heating_hot_water_split(start_date, end_date))

  results.merge!(calculate_implied_litres_per_pupil(school, results))

  results
end

def annual_kwh(meter, start_date, end_date, adjusted_heating, data_type)
  if meter.fuel_type == :electricity || !adjusted_heating
    meter.amr_data.kwh_date_range(start_date, end_date, data_type)
  else
    meter.amr_data.kwh_date_range(start_date, end_date, data_type)
  end
end

school_results = {}

school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

schools = school_names.map do |school_name|
  school = school_factory.load_or_use_cached_meter_collection(:name, school_name, source_db)
  meter = school.aggregate_meter(:gas)

  next if meter.nil? || meter.amr_data.days < 364 || meter.heating_only?

  school_results[school.name] = analyse_meter(school, meter)

rescue => e
  puts e.message
end

ap school_results

save_csv(school_results)
