require 'require_all'
require_relative '../../lib/dashboard.rb'
require_all './test_support/'

module Logging
  filename = File.join(TestDirectory.instance.log_directory, 'optimum start analysis ' + Time.now.strftime('%H %M') + '.log')
  @logger = Logger.new(filename)
  logger.level = :debug
end

def save_csv(results)
  filename = File.join(TestDirectory.instance.results_directory('modelling'), 'optimum start.csv')

  puts "Writing results to #{filename}"

  ap results, { limit: 4 }

  column_names = results.values.first.values.first.map { |type, data| data.keys.map { |t| "#{type}: #{t}" } }.flatten

  CSV.open(filename, 'w') do |csv|
    csv << ['School name', 'mpxn', column_names].flatten

    results.each do |name, school_data|
      next if school_data.nil?
      school_data.each do |mpxn, d|
        next if d.nil?
        row_data = d.map { |type, data| data.values }.flatten
        csv << [name, mpxn, row_data].flatten
      end
    end
  end
end


def school_optimum_start_analysis(school)
  meters = BoilerStartAndEndTimeAnalysis.all_gas_meters(school)

  results = {}

  meters.each do |meter|
    analyser = BoilerStartAndEndTimeAnalysis.new(school, meter)

    results[meter.analytics_name] = {}
    results[meter.analytics_name][:interpretation] = analyser.interpret
    results[meter.analytics_name].merge!(analyser.analyse)
  end

  results
end

school_pattern_match = ['*']
results = {}

source = :unvalidated_meter_data

school_list = SchoolFactory.instance.school_file_list(source, school_pattern_match)

school_list.sort.each do |school_name|
  school = SchoolFactory.instance.load_school(source, school_name)
  results[school.name] = school_optimum_start_analysis(school)
end

save_csv(results)
