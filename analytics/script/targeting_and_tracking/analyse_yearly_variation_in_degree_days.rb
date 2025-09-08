# finds unique example schools for each region
# calculates annual historic degree days
# saves to CSV file for analysis
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/degree day analysis ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def calc_years(temperature_start_date, temperature_end_date, today)
  years = []
  while today - 365 > temperature_start_date
    years.push((today -365)..today)
    today -= 365
  end
  years
end

def degree_days_by_year(school, today)
  temperatures = school.temperatures

  years = calc_years(temperatures.start_date, temperatures.end_date, today)

  years.map do |year|
    [
      year,
      school.temperatures.degree_days_in_date_range(year.first, year.last)
    ]
  end.to_h
end

def unique_years(example_schools)
  unique_years = []

  # flatten doesn't work?
  example_schools.values.each do |year_dates|
    year_dates.keys.each do |year_date|
      unique_years.push(year_date)
    end
  end

  unique_years.uniq.sort{ |a,b| a.first <=> b.first }
end

def degree_days_by_year_lookup(year_columns, degree_days_by_year)
  year_columns.each.map do |year_dates|
    degree_days_by_year[year_dates]
  end
end

def format_year_columns(year_columns)
  year_columns.map do |year_date_range|
    "#{year_date_range.first.strftime('%Y')}-#{year_date_range.last.strftime('%Y')}"
  end
end

def save_csv(example_schools)
  year_columns = unique_years(example_schools)
  year_col_names = format_year_columns(year_columns)
  filename = "./Results/annual degree day data by region.csv"
  puts "Saving results to #{filename}"
  CSV.open(filename, 'w') do |csv|
    csv << ['Example regional school', year_col_names].flatten
    example_schools.each do |school_name, degree_days_by_year|
      dd_by_year = degree_days_by_year_lookup(year_columns, degree_days_by_year)
      csv << [school_name, dd_by_year].flatten
    end
  end
end

def aggregate_degree_days_by_school_unique_key(school_data)
  school_data.transform_values{ |years| years.values.sum }
end

def unique_school_by_degree_days(school_data)
  school_by_aggregate_degree_day = aggregate_degree_days_by_school_unique_key(school_data)

  unique_list = {}

  school_by_aggregate_degree_day.each do |school_name, aggregate_degree_days|
    unique_list[school_name] = aggregate_degree_days unless unique_list.values.include?(aggregate_degree_days)
  end

  school_data.select { |school_name, _degree_day_years| unique_list.key?(school_name) }
end


school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data

today = Date.new(Date.today.year, 7, 15) # roughly mid summer from temperature perspective

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

data_by_school = {}

school_names.each do |school_name|
  school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)

  data_by_school[school_name] = degree_days_by_year(school, today)
end

example_school_per_degree_day_region  = unique_school_by_degree_days(data_by_school)

save_csv(example_school_per_degree_day_region)
