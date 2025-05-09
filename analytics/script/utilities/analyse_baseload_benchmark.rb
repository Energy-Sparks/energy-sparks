require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'
require 'tzinfo'

module Logging
  @logger = Logger.new('log/baseload benchmark calculation ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def analyse_meter(school, meter)
  end_date = meter.amr_data.end_date
  start_date = [end_date - 365, meter.amr_data.start_date].max
  baseload_kw = Baseload::BaseloadAnalysis.new(meter).average_baseload_kw(start_date, end_date)
  benchmark_baseload_kw = BenchmarkMetrics.recommended_baseload_for_pupils(school.number_of_pupils, school.school_type)
  {
    school_name:        school.name,
    type:               school.school_type,
    pupils:             school.number_of_pupils,
    benchmark_baseload: benchmark_baseload_kw,
    baseload_kw:        baseload_kw,
  }
end

def save_to_csv(data)
  dir = TestDirectory.instance.results_directory('modelling')
  filename = File.join(dir, 'baseload benchmark analysis.csv')

  puts "Saving to #{filename}"

  CSV.open(filename, 'w') do |csv|
    csv << data.first.keys
    data.each do |row|
      csv << row.values
    end
  end
end


school_name_pattern_match = ['*']
source = :unvalidated_meter_data
school_names = SchoolFactory.instance.school_file_list(source, school_name_pattern_match)
data = []

school_names.each do |school_name|
  begin
    school = SchoolFactory.instance.load_school(source, school_name, cache: false)
    data.push(analyse_meter(school, school.aggregated_electricity_meters)) unless school.aggregated_electricity_meters.nil?
  rescue => e
    puts "#{school_name} #{e.message}"
    puts e.backtrace
  end
end

save_to_csv(data)
