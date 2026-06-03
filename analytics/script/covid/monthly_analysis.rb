# adhoc COVID calculations
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/adhoc covid monthly analysis ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def school_factory
  $SCHOOL_FACTORY ||= SchoolFactory.new
end


def analysis_month_years(start_date, end_date)
  last_day_of_end_month = Date.new(end_date.year, end_date.month, 1) - 1
  first_of_month = start_date.month == 12 ? Date.new(start_date.year + 1, 1, 1) : Date.new(start_date.year, start_date.month + 1, 1)

  month_dates = []
  while first_of_month < last_day_of_end_month
    last_day_of_month = DateTimeHelper.last_day_of_month(first_of_month)
    month_dates.push(first_of_month..last_day_of_month)
    first_of_month = last_day_of_month + 1
  end

  whole_years = (month_dates.length / 12)

  month_dates.reverse[0...(whole_years * 12)].reverse.each_slice(12).to_a
end

def analyse_date_ranges(meter, fuel_type, same_months_of_year, adjusted_heating)
  school = meter.meter_collection
  kwhs_by_date = {}

  if fuel_type == :electricity || !adjusted_heating
    same_months_of_year.each do |month|
      end_date = [month.last, meter.amr_data.end_date].min # somerset fudge factor to get more schools data, allow some schools with incomplete August data to be included
      kwhs_by_date[month] = meter.amr_data.kwh_date_range(month.first, end_date)
    end
  else
    kwhs_by_date = HotWaterHeatingSplitter.new(school, fault_tolerant_model_dates: true).degree_day_adjust_heating(same_months_of_year, meter: meter, adjustment_method: :average)
  end

  kwhs_by_date
end

def analyse_school(school, fuel_type, adjusted_heating, somerset_late_days = 4)
  meter = school.aggregate_meter(fuel_type)
  return {} if meter.nil?
  return {} if meter.amr_data.end_date + somerset_late_days < DateTimeHelper.first_day_of_month(Date.today)

  month_kwhs = {}

  month_years = analysis_month_years(meter.amr_data.start_date, meter.amr_data.end_date)

  (0...12).each do |month_number|
    same_months_of_year = month_years.map { |year| year[month_number] }
    month_in_different_year_kwhs = analyse_date_ranges(meter, fuel_type, same_months_of_year, adjusted_heating)
    month_kwhs.merge!(month_in_different_year_kwhs)
  end

  years_by_months_normalised_kwhs = normalise_years_to_1(month_kwhs)
end

def normalise_years_to_1(month_kwhs)
  sorted_month_kwhs = month_kwhs.sort_by{ |k, v| k.first }.to_h

  sorted_month_kwhs.each_slice(12).to_a.map do |one_year_months|
    date_ranges = one_year_months.map(&:first)
    kwhs = one_year_months.map(&:last)
    total_year_kwh = kwhs.sum
    [
      date_ranges.first.first.year..date_ranges.last.last.year,
      kwhs.map { |month_kwh| month_kwh / total_year_kwh }
    ]
  end.to_h
end

def save_csv(results, funding_status, fuel_type)
  filename = "./Results/annual monthly #{fuel_type}.csv"
  puts "Saving results to #{filename}"

  CSV.open(filename, 'w') do |csv|
    csv << ['school name', 'funding status', 'year'].flatten
    results.each do |school_name, fuel_type_years|
      next if fuel_type_years[fuel_type].nil?

      fuel_type_years[fuel_type].each do |year_range, months_data_x12|
        csv << [school_name, funding_status[school_name], year_range, months_data_x12].flatten
      end
    end
  end
end

school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data
today = Date.new(2021, 9, 6)
adjusted_heating = true  # temperature adjust heating?

results = {}
funding_status = {}
months_kwhs = {}

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

schools = school_names.map do |school_name|
  school = school_factory.load_or_use_cached_meter_collection(:name, school_name, source_db)

  %i[electricity gas storage_heater].each do |fuel_type|
    data = analyse_school(school, fuel_type, adjusted_heating)

    unless data.empty?
      months_kwhs[school.name] ||= {}
      months_kwhs[school.name][fuel_type] = data
      funding_status[school.name] = school.funding_status
    end
  end
rescue => e
  puts e.message
  puts e.backtrace
end

save_csv(months_kwhs, funding_status, :electricity)
save_csv(months_kwhs, funding_status, :gas)
save_csv(months_kwhs, funding_status, :storage_heater)

