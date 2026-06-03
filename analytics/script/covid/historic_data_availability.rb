# adhoc COVID calculations
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/adhoc covid ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def school_factory
  $SCHOOL_FACTORY ||= SchoolFactory.new
end

def save_csv(results, funding_status, type)
  filename = "./Results/annual by fuel consumptions #{type}.csv"
  puts "Saving results to #{filename}"

  uy = unique_years(results, type)

  CSV.open(filename, 'w') do |csv|
    csv << ['school name', 'funding status', 'fuel type', 'can analyse',  uy].flatten
    results.each do |school_name, fuel_type_years|
      fuel_type_years.each do |fuel_type, annual_kwhs|
        next if annual_kwhs[type].nil?

        annual_kwh_by_year = uy.map { |y_y| annual_kwhs[type][y_y] }
        csv << [school_name, funding_status[school_name], fuel_type, can_analyse?(fuel_type, annual_kwhs[type]), annual_kwh_by_year].flatten
      end
    end
  end
end

def unique_years(results, type)
  years = []
  results.each do |school_name, school_data|
    school_data.each do |fuel_type, years_data|
      years = [years + years_data[type].keys ].flatten.uniq unless years_data.empty?
    end
  end
  years.sort_by { |year_range| year_range.first }
end

def open_times_x48(school)
  @open_times_x48 ||= {}
  @open_times_x48[school.name] ||= DateTimeHelper.weighted_x48_vector_multiple_ranges([school.open_time..school.close_time])
end

def school_day_open_close_kwh(meter, date)
  open_x48 = open_times_x48(meter.meter_collection)
  open_kwh = AMRData.fast_multiply_x48_x_x48(meter.amr_data.days_kwh_x48(date), open_x48).sum
  [open_kwh, meter.amr_data.one_day_kwh(date) - open_kwh]
end

def out_of_hours_consumption(meter, start_date, end_date)
  results = { holiday: [], weekend: [], school_day_open: [], school_day_closed: [] }
  (start_date..end_date).each do |date|
    day_type = meter.meter_collection.holidays.day_type(date)
    case day_type
    when :holiday, :weekend
      results[day_type].push(meter.amr_data.one_day_kwh(date))
    when :schoolday
      open_kwh, closed_kwh = school_day_open_close_kwh(meter, date)
      results[:school_day_open].push(open_kwh)
      results[:school_day_closed].push(closed_kwh)
    end
  end
  results
end

def out_of_hours_consumption_percent(meter, start_date, end_date)
  results = out_of_hours_consumption(meter, start_date, end_date)
  total = results.values.flatten.sum
  results.transform_values{ |v| v.empty? ? 0.0 : v.sum / total }
end

def percent_out_of_hours(meter, start_date, end_date)
  1.0 - out_of_hours_consumption_percent(meter, start_date, end_date)[:school_day_open]
end

def can_analyse?(fuel_type, annual_kwhs)
  return false if annual_kwhs.nil?

  case fuel_type
  when :electricity
    annual_kwhs.length >= 2
  when :gas, :storage_heaters
    annual_kwhs.length >= 2
  end
end

def years_history(meter, end_date)
  return {} if meter.amr_data.end_date + 30 < end_date # non-recent meter data

  splitter = HotWaterHeatingSplitter.new(meter.meter_collection)
  end_date = meter.amr_data.end_date

  years = { annual_kwh: {}, out_of_hours_percent: {}, heating_percent: {}}

  date_ranges = []

  while end_date - 365 >= meter.amr_data.start_date
    start_date = end_date - 365 + 1
    date_range = start_date.year..end_date.year
    years[:annual_kwh][date_range] = meter.amr_data.kwh_date_range(start_date, end_date)
    years[:heating_percent][date_range] = splitter.aggregate_heating_hot_water_split(start_date, end_date, meter: meter)[:heating_percent] if meter.fuel_type != :electricity
    years[:out_of_hours_percent][date_range] = percent_out_of_hours(meter, start_date, end_date)
    date_ranges.push(start_date..end_date)
    end_date = start_date - 1
  end

  years[:adjusted_annual_kwh] = meter.fuel_type == :electricity ? {} : calculate_adjusted_heating(splitter, date_ranges)

  years
end

def calculate_adjusted_heating(splitter, date_ranges)
  results = splitter.degree_day_adjust_heating(date_ranges)
  results.transform_keys{ |dr| dr.first.year..dr.last.year }
end

def calculate_energy_history(school, today)
  fuel_types = school.fuel_types(false, true)

  fuel_types.map do |fuel_type|
    meter = school.aggregate_meter(fuel_type)
    [
      fuel_type,
      years_history(meter, today)
    ]
  end.to_h
end

school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data
today = Date.new(2021, 9, 6)

results = {}
funding_status = {}

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

schools = school_names.map do |school_name|
  school = school_factory.load_or_use_cached_meter_collection(:name, school_name, source_db)

  results[school.name] = calculate_energy_history(school, today)
  funding_status[school.name] = school.funding_status
rescue => e
  puts e.message
  puts e.backtrace
end

save_csv(results, funding_status, :annual_kwh)
save_csv(results, funding_status, :out_of_hours_percent)
save_csv(results, funding_status, :heating_percent)
save_csv(results, funding_status, :adjusted_annual_kwh)

