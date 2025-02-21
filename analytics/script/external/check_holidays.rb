require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/holiday schedule integrity ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

ENV['ENERGYSPARKSMETERCOLLECTIONDIRECTORY'] +=  '\\Community'

def save_csv(data)
  filename = "./Results/holiday integrity check.csv"
  puts "Saving issues to #{filename}"
  CSV.open(filename, 'w') do |csv|
    data.each do |school_name, holiday_issues|
      holiday_issues.each do |holiday_issue|
        csv << [school_name, holiday_issue]
      end
    end
  end
end

school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

puts '=' * 80
puts 'Checking the integrity of the holiday schedule'

issues_by_school = {}

school_names.each do |school_name|
  school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)

  puts '-' * 80
  puts school.name

  issues_by_school[school.name] = school.holidays.check_school_holidays(school)
end

save_csv(issues_by_school)

ap issues_by_school.select { |k, v| !v.empty? }
