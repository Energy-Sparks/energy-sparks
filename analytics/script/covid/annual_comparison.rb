# adhoc COVID calculations
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/adhoc covid annual analysis ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

$dir = TestDirectory.instance.results_directory('Ovo Annual Comparison')

def unique_years(results, fuel_type_type, data_type_type)
  years = []
  results.each do |school_name, school_data|
    school_data.each do |fuel_type, fuel_type_data|
      fuel_type_data.each do |data_type, years_data|
        years.push(years_data.keys) if fuel_type_type == fuel_type && data_type_type == data_type
      end
    end
  end
  years.flatten.uniq.sort_by { |v| v.first }
end

def save_csv(results, meta_data_keys, meta_data, fuel_type, data_type)
  filename = File.join($dir, "annual #{fuel_type} #{data_type}.csv")
  puts "Saving results to #{filename}"

  years = unique_years(results, fuel_type, data_type)

  CSV.open(filename, 'w') do |csv|
    csv << ['school name', meta_data_keys, years].flatten
    results.each do |school_name, school_data|

      next if school_data[fuel_type].nil? || school_data[fuel_type][data_type].nil?

      data = school_data[fuel_type][data_type]
      year_data_with_nulls = years.map { |year_range| data[year_range] }

      csv << [school_name, meta_data[school_name].values, year_data_with_nulls].flatten
    end
  end
end

def calculate_total_per_pupil_aggregate(meta_data, data, calc_config, min_year)
  year_data = {}
  fuel_type = calc_config[:fuel_type]
  data_type = calc_config[:data_type]
  years = unique_years(data, fuel_type, data_type)
  year_data = years.select { |year_range| year_range.first >= min_year}.map { |y| [y, []] }.to_h

  data.each do |school_name, school_data|
    next if school_data[fuel_type].nil? || school_data[fuel_type][data_type].nil?
    next unless meta_data[school_name][:type] == calc_config[:school_type]
    school_data[fuel_type][data_type].each do |year_range, val|
      next unless year_range.first >= min_year
      year_data[year_range].push(val / meta_data[school_name][:pupils])
    end
  end

  {calc_config => year_data.transform_values { |v| v.empty? ? nil : v.sum / v.length }}
end

def calculate_aggregate_per_pupil_data(meta_data, data, min_year = 2017)
  calc_config = [
    { school_type: 'primary',     fuel_type: :electricity, data_type: :kwh },
    { school_type: 'secondary',   fuel_type: :electricity, data_type: :kwh },
    { school_type: 'primary',     fuel_type: :electricity, data_type: :co2 },
    { school_type: 'secondary',   fuel_type: :electricity, data_type: :co2 },

    { school_type: 'primary',     fuel_type: :gas, data_type: :kwh },
    { school_type: 'secondary',   fuel_type: :gas, data_type: :kwh },
    { school_type: 'primary',     fuel_type: :gas, data_type: :co2 },
    { school_type: 'secondary',   fuel_type: :gas, data_type: :co2 },

    { school_type: 'primary',     fuel_type: :gas, data_type: :adjusted_heating_kwh },
    { school_type: 'secondary',   fuel_type: :gas, data_type: :adjusted_heating_kwh },
    { school_type: 'primary',     fuel_type: :gas, data_type: :adjusted_heating_co2 },
    { school_type: 'secondary',   fuel_type: :gas, data_type: :adjusted_heating_co2 }
  ]

  results = calc_config.map do |calc|
    res = calculate_total_per_pupil_aggregate(meta_data, data, calc, min_year)
    [res.keys.first, res.values.first]
  end.to_h

  results
end

def save_aggregate_per_pupil_data_to_csv(meta_data, data)
  data = calculate_aggregate_per_pupil_data(meta_data, data)
  unique_years = data.values.map(&:keys).flatten.uniq

  filename = File.join($dir, "per pupil year data.csv")

  puts "Saving to #{filename}"
  CSV.open(filename, 'w') do |csv|
    csv << [data.keys.first.keys, unique_years].flatten
    data.each do |key, years|
      year_data = unique_years.map { |y_r| years[y_r] }
      csv << [key.values, year_data].flatten
    end
  end
end

def calculate_cumulative_pupil(meta_data)
  by_date = meta_data.values.map { |d| [d[:date], d[:pupils]] }.sort_by{ |d| d[0] }
  total = 0.0
  by_date.map { |d| total += d[1]; [d[0], total] }.to_h
end

def save_cumulative_pupils_to_csv(meta_data)
  filename = File.join($dir, "cumulative pupils.csv")

  puts "Saving to #{filename}"

  CSV.open(filename, 'w') do |csv|
    calculate_cumulative_pupil(meta_data).each do |date, culm_pupils|
      csv << [date, culm_pupils]
    end
  end
end

def moving_average_dates(moving_average_kwhs)
  dates = {}
  school_types = {}
  fuel_types = {}
  data_types = {}

  moving_average_kwhs.each do |school_type, school_type_data|
    school_types[school_type] = 1
    school_type_data.each do |fuel_type, data_type_data|
      fuel_types[fuel_type] = 1
      data_type_data.each do |data_type, dates_data|
        data_types[data_type] = 1
        dates_data.each do |date, _normalised_val|
          dates[date] = 1
        end
      end
    end
  end

  {
    school_types: school_types.keys.sort,
    fuel_types:   fuel_types.keys.sort,
    data_types:   data_types.keys.sort,
    dates:        dates.keys.sort
  }
end

def save_moving_averages_to_csv(moving_average_kwhs, file_type)
  filename = File.join($dir, "moving averages #{file_type}.csv")

  puts "Saving results to #{filename} x#{moving_average_kwhs.length}"
  keys = moving_average_dates(moving_average_kwhs)
  CSV.open(filename, 'w') do |csv|
    csv << ['school type', 'fuel', 'data type', keys[:dates]].flatten
    keys[:school_types].each do |school_type|
      keys[:fuel_types].each do |fuel_type|
        keys[:data_types].each do |data_type|
          vals = keys[:dates].map { |date| moving_average_kwhs.dig(school_type, fuel_type, data_type, date) }
          csv << [school_type, fuel_type, data_type, vals].flatten
        end
      end
    end
  end
end

def save_start_end_dates_to_csv(aggregated_meter_start_end_dates, meta_data)
  filename = File.join($dir, "aggregated meter start-end dates.csv")

  puts "Saving to #{filename}"
  CSV.open(filename, 'w') do |csv|
    aggregated_meter_start_end_dates.each do |school_name, fuel_data|
      fuel_data.each do |fuel_type, sd_ed_range|
        csv << [school_name, fuel_type, sd_ed_range.first, sd_ed_range.last, meta_data[school_name][:date]]
      end
    end
  end
end

def load_activation_dates
  # downloaded from https://energysparks.uk/admin/school_setup/completed, cut and paste into Excel, save
  filename = File.join($dir, "school activation dates.csv")

  puts "Loading activation dates from #{filename}"
  data = CSV.read(filename)
  data.drop(1).map { |row| [row[0], parse_activation_date(row[2])]}.to_h
end

def parse_activation_date(date)
  dow, dom, month, year, time_str = date.split(' ')
  Date.strptime("#{dom.to_i} #{month} #{year}", '%d %b %Y')
end

def previous_year(date)
  Date.new(date.year - 1, date.month, date.day)
end

def calculate_years(start_date, end_date)
  year_date_ranges = []

  while previous_year(end_date) >= start_date
    year_date_ranges.push((previous_year(end_date) + 1)..end_date)
    end_date = previous_year(end_date)
  end
  year_date_ranges.reverse
end

def analyse_school(school, fuel_type, adjusted_heating, data_type, activation_date, today)
  meter = school.aggregate_meter(fuel_type)
  return {} if meter.nil?
  return {} if meter.amr_data.end_date < today

  annual_kwhs = {}

  # only analyse schools after they have started with ES, using data from 1 year before
  start_date = activation_date.nil? ? meter.amr_data.start_date : [meter.amr_data.start_date, activation_date - 365].max
  end_date   = [meter.amr_data.end_date,   today                ].min

  year_date_ranges = calculate_years(start_date, end_date)

  return {} if year_date_ranges.empty?

  if adjusted_heating
    splitter = HotWaterHeatingSplitter.new(school, fault_tolerant_model_dates: true)
    adjusted = splitter.degree_day_adjust_heating(year_date_ranges, meter: meter, adjustment_method: :average, data_type: data_type)
    adjusted.transform_keys{ |k| k.first.year..k.last.year }
  else
    year_date_ranges.map do |year_date_range|
      end_date = [year_date_range.last, meter.amr_data.end_date].min
      [
        year_date_range.first.year..year_date_range.last.year,
        annual_kwh(meter, year_date_range.first, end_date, adjusted_heating, data_type)
      ]
    end.to_h
  end
end

def annual_kwh(meter, start_date, end_date, adjusted_heating, data_type)
  if meter.fuel_type == :electricity || !adjusted_heating
    meter.amr_data.kwh_date_range(start_date, end_date, data_type)
  else
    meter.amr_data.kwh_date_range(start_date, end_date, data_type)
  end
end

def carbon_intensities(school_data)
  school_data.each do |fuel_type, annual_kwh_and_co2|
    next if annual_kwh_and_co2[:kwh].nil?

    annual_kwh_and_co2[:kwh].each do |year_range, kwh|
      annual_kwh_and_co2[:co2_per_kwh] ||= {}
      annual_kwh_and_co2[:co2_per_kwh] [year_range] = (annual_kwh_and_co2[:co2][year_range] / kwh).round(3)
    end
  end
end

def moving_average_consumption(school, fuel_type, data_type, activation_date = nil)
  meter = school.aggregate_meter(fuel_type)
  return {} if meter.nil?

  sd = [meter.amr_data.start_date, activation_date].compact.max
  return {} if meter.amr_data.end_date - sd + 1 < 365

  ed = meter.amr_data.end_date - 365

  avg = {}

  avg[sd + 364] = meter.amr_data.kwh_date_range(sd, sd + 364, data_type)
  ((sd + 1)..ed).each do |date|
    avg[date + 364] = avg[date + 363] - meter.amr_data.one_day_kwh(date - 1, data_type) + meter.amr_data.one_day_kwh(date + 364, data_type)
  end

  scale = normalise(school, fuel_type)

  avg.transform_values{ |d| d * scale }
end

def moving_average_consumptions(data, school, fuel_type, data_type, activation_date = nil)
  data[school.school_type] ||= {}
  data[school.school_type][fuel_type] ||= {}
  data[school.school_type][fuel_type][data_type] ||= {}

  moving_average_consumption(school, fuel_type, data_type, activation_date).each do |date, val|
    data[school.school_type][fuel_type][data_type][date] ||= []

    data[school.school_type][fuel_type][data_type][date].push(val)
  end

  data
end

def average_moving_averages(moving_average_kwhs)
  moving_average_kwhs.each do |school_type, school_type_data|
    school_type_data.each do |fuel_type, data_type_data|
      data_type_data.each do |data_type, dates_data|
        dates_data.transform_values! { |kwhs| kwhs.sum / kwhs.length }
      end
    end
  end
end

def normalise(school, fuel_type)
  case fuel_type
  when :electricity
    1.0 / school.number_of_pupils
  when :gas, :storage_heater, :storage_heaters
    1.0 / school.floor_area
  end
end

def school_meta_data(school)
  @activation_dates ||= load_activation_dates
  meta_data = {}
  meta_data[:area_name]           = school.area_name
  meta_data[:funding_status]      = school.funding_status
  meta_data[:type]                = school.school_type
  meta_data[:creation_date]       = school.creation_date
  meta_data[:activation_date]     = school.activation_date
  meta_data[:activation_date2]    = @activation_dates[school.activation_date]
  meta_data[:date]                = meta_data.select { |k, _v| k.to_s.match?(/date/) }.values.compact.max
  meta_data[:floor_area]          = school.floor_area
  meta_data[:pupils]              = school.number_of_pupils
  meta_data[:electricity]         = school.electricity?
  meta_data[:gas]                 = school.gas?
  meta_data[:storage_heaters]     = school.storage_heaters?
  meta_data[:sheffield_solar_pv]  = school.sheffield_simulated_solar_pv_panels?
  meta_data[:sheffield_solar_pv]  = school.sheffield_simulated_solar_pv_panels?
  meta_data[:metered_solar_pv]    = school.solar_pv_real_metering?
  meta_data
end

def calculate_aggregated_meter_start_end_dates(school)
  dates = {}
  %i[electricity gas storage_heater].each do |fuel_type|
    meter = school.aggregate_meter(fuel_type)
    next if meter.nil?
    dates[fuel_type] = Range.new(meter.amr_data.start_date, meter.amr_data.end_date)
  end
  dates
end

ENV['ENERGYSPARKSMETERCOLLECTIONDIRECTORY'] +=  '\\Community'
school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data
today = Date.new(2022, 6, 20) # warning will exclude schools whose meter data is not up to date, so today ~= reporting date
use_activation_date = false # generally avoid the activation date as it reduces the amount of data for analysis
include_private_schools = false
meta_data = {}
annual_kwhs = {}
moving_average_kwhs = {}
moving_average_kwhs_since_energy_sparks = {}
aggregated_meter_start_end_dates = {}

school_names = SchoolFactory.instance.school_file_list(source_db, school_name_pattern_match)

schools = school_names.map do |school_name|
  school = SchoolFactory.instance.load_school(source_db, school_name, cache: false)

  next if school.funding_status == :private && !include_private_schools

  meta_data[school.name] = school_meta_data(school)
  aggregated_meter_start_end_dates[school.name] = calculate_aggregated_meter_start_end_dates(school)
  @meta_data_keys ||= meta_data[school.name].keys

  %i[co2 kwh].each do |data_type|
    %i[electricity gas storage_heater].each do |fuel_type|

      moving_average_consumptions(moving_average_kwhs, school, fuel_type, data_type)
      # calculate versus 1 year before starting with Energy Sparks
      moving_average_consumptions(moving_average_kwhs_since_energy_sparks, school, fuel_type, data_type, meta_data[school.name][:date] - 365)

      activation_date = use_activation_date ? meta_data[school.name][:date] : nil

      data = analyse_school(school, fuel_type, false, data_type, activation_date, today)

      unless data.empty?
        annual_kwhs[school.name] ||= {}
        annual_kwhs[school.name][fuel_type] ||= {}
        annual_kwhs[school.name][fuel_type][data_type] = data

        if %i[gas storage_heater].include?(fuel_type)
          adjusted_data_type_key = "adjusted_heating_#{data_type}".to_sym
          annual_kwhs[school.name][fuel_type][adjusted_data_type_key] = analyse_school(school, fuel_type, true, data_type, activation_date, today)
        end
      end
    end
  end
rescue => e
  puts e.message
  puts e.backtrace
end

average_moving_averages(moving_average_kwhs)
save_moving_averages_to_csv(moving_average_kwhs, 'since start')

average_moving_averages(moving_average_kwhs_since_energy_sparks)
save_moving_averages_to_csv(moving_average_kwhs_since_energy_sparks, 'since energy sparks')

annual_kwhs.each do |school_name, school_data|
  carbon_intensities(school_data)
end

save_cumulative_pupils_to_csv(meta_data)
save_aggregate_per_pupil_data_to_csv(meta_data, annual_kwhs)

save_csv(annual_kwhs, @meta_data_keys, meta_data, :electricity, :co2)
save_csv(annual_kwhs, @meta_data_keys, meta_data, :electricity, :kwh)
save_csv(annual_kwhs, @meta_data_keys, meta_data, :electricity, :co2_per_kwh)
save_csv(annual_kwhs, @meta_data_keys, meta_data, :gas,         :adjusted_heating_co2)
save_csv(annual_kwhs, @meta_data_keys, meta_data, :gas,         :adjusted_heating_kwh)
save_csv(annual_kwhs, @meta_data_keys, meta_data, :gas,         :co2_per_kwh)

save_start_end_dates_to_csv(aggregated_meter_start_end_dates, meta_data)
