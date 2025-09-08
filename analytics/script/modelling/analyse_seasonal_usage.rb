require 'require_all'
require_relative '../../lib/dashboard.rb'
require_all './test_support/'

module Logging
  @logger = @logger = Logger.new(File.join(TestDirectory.instance.log_directory, 'seasonal analysis.log'))
  logger.level = :debug
end

def save_csv(data)
    dir = TestDirectory.instance.test_directory_name('modelling')
    filename = File.join(dir, 'seasonal analysis.csv')

    puts "Saving results to #{filename}"
    day_types = %i[schoolday weekend holiday]
    heat_types = %i[heating_cold_weather heating_warm_weather heating_off]
    data_types = %i[kwh £ co2 days degree_days]

    column_names = day_types.product(heat_types).product(data_types).map(&:flatten).map{ |vs| vs.join(' ') }

    CSV.open(filename, 'w') do |csv|
      csv << ['school name', column_names].flatten
      data.each do |school_name, analysis|
        row = []
        day_types.each do |day_type|
          heat_types.each do |heat_type|
            data_types.each do |data_type|
              row.push(analysis.dig(day_type, heat_type, data_type))
            end
          end
        end
        csv << [school_name, row].flatten
      end
    end
end

school_pattern_match = ['*']
source = :unvalidated_meter_data
analysis = {}

school_list = SchoolFactory.instance.school_file_list(source, school_pattern_match)

school_list.sort.each do |school_name|
  school = SchoolFactory.instance.load_school(source, school_name)
  meter = school.aggregated_heat_meters
  next if meter.nil? || meter.amr_data.days < 364

  start_date = [meter.amr_data.end_date - 365, meter.amr_data.start_date].max
  last_year = SchoolDatePeriod.new(:analysis, 'validate amr', start_date, meter.amr_data.end_date)
  model = meter.heating_model(last_year)
  analysis[school.name] = model.heating_on_seasonal_analysis

rescue => e
  puts e.message
end

save_csv(analysis)
