require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'
require 'tzinfo'

module Logging
  @logger = Logger.new('log/2330 electric data issue ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def analyse_meter(school, meter)
  start_date = meter.amr_data.start_date
  end_date = meter.amr_data.end_date
  baseload_kw = Baseload::BaseloadAnalysis.new(meter).average_baseload_kw(start_date, end_date)
  cnt = (start_date..end_date).count do |date|
    missing_23_30_value?(meter.amr_data.days_kwh_x48(date))
  end

  pct = 1.0 * cnt / (end_date - start_date + 1)

  {
    school_name:  school.name,
    mprn:         meter.mpxn,
    percent:      pct,
    baseload_kw:  baseload_kw,
    sheffield_pv:   meter.sheffield_simulated_solar_pv_panels?
  }
end

def save_to_csv(data)
  dir = TestDirectory.instance.results_directory('modelling')
  filename = File.join(dir, 'zero 2330 issue.csv')

  puts "Saving to #{filename}"

  CSV.open(filename, 'w') do |csv|
    csv << ['name','mprn', 'percent with zero 2300', 'baseload', 'sheff pv']
    data.each do |row|
      csv << row.values
    end
  end
end

def missing_23_30_value?(kwh_x48)
  kwh_x48.count { |kwh| kwh == 0.0 } == 1 && kwh_x48[47] == 0.0
end

school_name_pattern_match = ['*']
source = :unvalidated_meter_data
school_names = SchoolFactory.instance.school_file_list(source, school_name_pattern_match)
data = []

school_names.each do |school_name|
  begin
    school = SchoolFactory.instance.load_school(source, school_name, cache: false)
    school.electricity_meters.each do |meter|
      data.push(analyse_meter(school, meter))
    end
  rescue => e
    puts "#{school_name} #{e.message}"
    puts e.backtrace
  end
end

save_to_csv(data)
