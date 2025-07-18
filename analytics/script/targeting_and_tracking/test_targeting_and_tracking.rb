require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/targetting startup ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def test_script_config(school_name_pattern_match, source_db, attribute_overrides)
  {
    logger1:          { name: TestDirectory.instance.log_directory + "/target %{time}.log", format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
    schools:          school_name_pattern_match,
    source:           source_db,
    meter_attribute_overrides:  attribute_overrides,
    logger2:          { name: "./log/pupil dashboard %{school_name} %{time}.log", format: "%{datetime} %{severity.ljust(5, ' ')}: %{msg}\n" },
    adult_dashboard:  {
                        control: {
                          root:    :adult_analysis_page,
                          display_average_calculation_rate: true,
                          summarise_differences: true,
                          report_failed_charts:   :summary,
                          user: { user_role: :analytics, staff_role: nil },
                          pages: %i[electric_target gas_target storage_heater_target],

                          compare_results: [
                            { comparison_directory: ENV['ANALYTICSTESTRESULTDIR'] + '\Target\Base' },
                            { output_directory:     ENV['ANALYTICSTESTRESULTDIR'] + '\Target\New' },
                            :summary,
                            :report_differences,
                            :report_differing_charts,
                          ]
                        }
                      }
  }
end

def set_meter_attributes(schools, start_date = Date.new(2020, 9, 1), target = 0.9)
  schools.each do |school|
    %i[electricity gas storage_heater].each do |fuel_type|
      meter = school.aggregate_meter(fuel_type)
      next if meter.nil?

      attributes = meter.meter_attributes

      attributes[:targeting_and_tracking] = [
          {
            start_date: start_date,
            target:     target
          }
        ]

      pseudo_attributes = { Dashboard::Meter.aggregate_pseudo_meter_attribute_key(fuel_type) => attributes }
      school.merge_additional_pseudo_meter_attributes(pseudo_attributes)
    end
  end
end

def school_factory
  $SCHOOL_FACTORY ||= SchoolFactory.new
end

school_name_pattern_match = ['b*']
source_db = :unvalidated_meter_data

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

schools = school_names.map do |school_name|
  school_factory.load_or_use_cached_meter_collection(:name, school_name, source_db)
end

set_meter_attributes(schools)

script = test_script_config(school_name_pattern_match, source_db, {})
RunTests.new(script).run
