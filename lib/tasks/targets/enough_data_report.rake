namespace :targets do
  desc 'Run report to check data availability for targets feature'
  task enough_data_report: [:environment] do
    puts "#{Time.zone.now} Generating enough-data report"
    CSV.open("/tmp/enough-data-report.csv", "w") do |csv|
      csv << ["Group",
              "School",
              "Visible?",
              "Data Visible?",
              "Fuel type",
              "Target set?",
              "Holidays?",
              "Temperature?",
              "Readings?",
              "Annual estimate needed?",
              "Annual estimate set?",
              "Can calculate synthetic data?"]
      SchoolGroup.main_groups.each do |school_group|
        service = Targets::SchoolGroupTargetDataReportingService.new(school_group)
        data = service.report
        data.each do |school, school_result|
          [:electricity, :gas, :storage_heater].each do |fuel_type|
            if school_result[fuel_type].present?
              csv << [
                school_group.name,
                school_result.school.name,
                school_result.school.visible,
                school_result.school.data_enabled,
                fuel_type,
                school_result[fuel_type][:target_set],
                school_result[fuel_type][:holidays],
                school_result[fuel_type][:temperature],
                school_result[fuel_type][:readings],
                school_result[fuel_type][:estimate_needed],
                school_result[fuel_type][:estimate_set],
                school_result[fuel_type][:calculate_synthetic_data]
              ]
            end
          end
        end
      end
    end
    puts "#{Time.zone.now} Finished enough-data report"
  end
end
