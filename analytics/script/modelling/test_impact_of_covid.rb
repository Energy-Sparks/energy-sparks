# research to try to determine the impact of COVID and
# reduced school occupancy post March 2020
# Expected summer occupancy:
# - key workers and vulnerable - normal school days
# - Primary: from June 1st or 8th, Reception, Year 1, Year 6 so 3/7 of school
# - Middle: yesr 6 from 1/6 or 8/6????
# - Secondary: year 10, 12 for tutor groups some practical experiments
# - unclear whether teachers providing remote lessons worked from home or school
require 'require_all'
require_relative '../lib/dashboard.rb'
require_rel '../test_support'
require './script/report_config_support.rb'
require 'ruby-prof'
require 'csv'

class COVIDMeterAnalysis
  START_OF_LOCKDOWN = Date.new(2020, 3, 23)
  DATE_IN_SUMMER_HOLIDAYS = Date.new(2020, 8, 9) # Scottish and English schools
  COVID_DATE_RANGE = START_OF_LOCKDOWN..DATE_IN_SUMMER_HOLIDAYS
  WEEKS = COVID_DATE_RANGE.each_slice(7).map { |week| week }

  def initialize(school, meter)
    @school = school
    @meter = meter
  end

  def valid_meter
    return 'Solar meter' if @meter.solar_pv_panels?
    return 'Starts after Mar 2019' if @meter.amr_data.start_date > Date.new(2019, 3, 30)
    return 'Stops before May 2020' if @meter.amr_data.end_date   < Date.new(2020, 5, 20)
    nil
  end

  def meter_ranges
    [@school.name, fuel_type, @meter.amr_data.start_date, @meter.amr_data.end_date]
  end

  def fuel_type; 'error' end

  def process
    puts "Doing #{@meter.mpan_mprn}"
    if valid_meter.nil?
      {
        school_name:                                              @school.name,
        mpan_mprn:                                                @meter.mpan_mprn,
        meter_name:                                               @meter.name,
        fuel_type:                                                fuel_type,
        average_summer_holiday_work_day_daily_consumption_kwh:    average_summer_holiday_work_day_daily_consumption_kwh,
        average_summer_school_day_daily_consumption_kwh:          average_summer_school_day_daily_consumption_kwh,
        number_of_days_occupied_days_during_lockdown:             number_of_days_occupied_days_during_lockdown,
        percent_normal_energy_use_during_lockdown_schools_weeks:  percent_normal_energy_use_during_lockdown_schools_weeks
      }
    else
      puts "Skipped meter because #{valid_meter}"
      nil
    end
  end

  private

  def number_of_days_occupied_days_during_lockdown(above_percent = 0.5)
    COVID_DATE_RANGE.each.count do |date|
      meter_date_exists?(date) && days_kwh(date) > daily_occupied_criteria_kwh
    end
  end


  def percent_normal_energy_use_during_lockdown_schools_weeks
    lockdown_school_weeks.map do |dates_in_school_week|
      percents_of_normal_energy_usage = dates_in_school_week.map{ |date| percent_of_normal_energy_use(date) }
      [
        dates_in_school_week.first,
        percents_of_normal_energy_usage.sum / percents_of_normal_energy_usage.count
      ]
    end.to_h
  end

  # [ [Monday1, Tuesday1....Friday1], .... [MondayN...... FridayN]
  def lockdown_school_weeks
    school_weeks = WEEKS.select{ |week| week.count{ |date| school_day?(date) } > 3 }
    school_weeks.map do |school_week_dates|
      school_week_dates.select{ |date| school_day?(date)}
    end
  end

  def percent_of_normal_energy_use(date)
    percent_of_normal_use(average_summer_holiday_work_day_daily_consumption_kwh,
                          average_summer_school_day_daily_consumption_kwh,
                          days_kwh(date))
  end

  def percent_of_normal_use(low, high, value)
    (value - low) / (high - low)
  end

  def daily_occupied_criteria_kwh(above_percent = 0.5)
    average_summer_holiday_work_day_daily_consumption_kwh +
    (above_percent *
    (average_summer_school_day_daily_consumption_kwh - average_summer_holiday_work_day_daily_consumption_kwh))
  end

  def average_summer_holiday_work_day_daily_consumption_kwh
    @average_summer_holiday_kwh ||= calc_average_summer_holiday_work_day_daily_consumption_kwh
  end

  def calc_average_summer_holiday_work_day_daily_consumption_kwh
    kwhs = []
    (Date.new(2019, 5, 30)..Date.new(2020, 9, 10)).each do |date|
      kwhs.push(days_kwh(date)) if summer_holiday_workday?(date)
    end
    kwhs.sum / kwhs.count
  end

  def days_kwh(date)
    @meter.amr_data.one_day_kwh(date)
  end

  def average_summer_school_day_daily_consumption_kwh
    @average_summer_school_daya ||= calc_average_summer_school_day_daily_consumption_kwh
  end

  def calc_average_summer_school_day_daily_consumption_kwh
    kwhs = []
    (Date.new(2019, 5, 30)..Date.new(2019, 9, 10)).each do |date|
      kwhs.push(days_kwh(date)) if summer_schoolday?(date)
    end
    kwhs.sum / kwhs.count
  end

  def meter_date_exists?(date)
    @meter.amr_data.date_exists?(date)
  end

  def summer_holiday_workday?(date)
    date.month.between?(5,9) && DateTimeHelper.weekend?(date) &&
      @school.holidays.holiday?(date) && meter_date_exists?(date)
  end

  def summer_schoolday?(date)
    date.month.between?(5,9) && school_day?(date)
  end

  def school_day?(date)
    !DateTimeHelper.weekend?(date) && !@school.holidays.holiday?(date) && meter_date_exists?(date)
  end
end

class COVIDElectricityMeterAnalysis < COVIDMeterAnalysis
  def fuel_type; 'electricity' end
end

class COVIDHeatMeterAnalysis < COVIDMeterAnalysis
  def fuel_type; 'gas' end
end

class COVIDStorageHeaterMeterAnalysis < COVIDMeterAnalysis
  def fuel_type; 'storage heater' end
end

def save_to_excel(data, dates)
  data = data.compact
  filename = 'Results\covid analysis.xlsx'
  workbook = WriteXLSX.new(filename)
  worksheet = workbook.add_worksheet('Summer2020')

  worksheet.write(0, 0, ['school', 'mpan mprn', 'meter name', 'fuel type', 'avg hol kWh', 'avg school day kWh', 'occupied days', dates].flatten)
  data.each_with_index do |meter_data, row|
    row_data = [
      meter_data[:school_name],
      meter_data[:mpan_mprn],
      meter_data[:meter_name],
      meter_data[:fuel_type],
      meter_data[:average_summer_holiday_work_day_daily_consumption_kwh],
      meter_data[:average_summer_school_day_daily_consumption_kwh],
      meter_data[:number_of_days_occupied_days_during_lockdown],
      dates.map { |date| meter_data[:percent_normal_energy_use_during_lockdown_schools_weeks][date] }
    ].flatten
    row_data = row_data.map{ |d| (d.is_a?(Float) && !d.finite?) ? nil : d } # ruby write_xlsx can't cope with NaNs!
    worksheet.write(row + 1, 0, row_data)
  end

  workbook.close
end

module Logging
  @logger = Logger.new('log/covid analyser ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

school_name_pattern_match = ['*']
source_db = :aggregated_meter_collection # :analytics_db

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

results = []

meter_ranges = true

if meter_ranges

  meter_ranges = []
  school_names.each do |school_name|
    school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)
    puts "==============================Doing #{school_name} ================================"
    unless school.aggregated_electricity_meters.nil?
      analyser = COVIDElectricityMeterAnalysis.new(school, school.aggregated_electricity_meters)
      meter_ranges.push(analyser.meter_ranges)
    end

    unless school.aggregated_heat_meters.nil?
      analyser = COVIDHeatMeterAnalysis.new(school, school.aggregated_heat_meters)
      meter_ranges.push(analyser.meter_ranges)
    end

    unless school.storage_heater_meter.nil?
      analyser = COVIDStorageHeaterMeterAnalysis.new(school, school.storage_heater_meter)
      meter_ranges.push(analyser.meter_ranges)
    end
  end

  filename = 'Results\covid meter dates.csv'

  CSV.open(filename, "w") do |csv|
    meter_ranges.each do |school_meter_range|
      csv << school_meter_range
    end
  end
else

  individual_meters = false

  school_names.each do |school_name|
    puts "==============================Doing #{school_name} ================================"

    school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)

    if individual_meters
      school.electricity_meters.each do |electricity_meter|
        analyser = COVIDElectricityMeterAnalysis.new(school, electricity_meter)
        results.push(analyser.process)
      end

      school.heat_meters.each do |heat_meter|
        analyser = COVIDHeatMeterAnalysis.new(school, heat_meter)
        results.push(analyser.process)
      end
    else
      unless school.aggregated_electricity_meters.nil?
        analyser = COVIDElectricityMeterAnalysis.new(school, school.aggregated_electricity_meters)
        results.push(analyser.process)
      end

      unless school.aggregated_heat_meters.nil?
        analyser = COVIDHeatMeterAnalysis.new(school, school.aggregated_heat_meters)
        results.push(analyser.process)
      end
    end

  end

  save_to_excel(results, COVIDMeterAnalysis::WEEKS.map{ |week| week.first })
end

