namespace :targets do
  desc 'Run report to check data availability for targets feature'
  task enough_data_report: [:environment] do
    puts "#{Time.zone.now} Generating enough-data report"
    CSV.open("/tmp/enough-data-report.csv", "w") do |csv|
      csv << ["Group", "School", "Visible?", "Fuel Type", "Holidays?", "Temperature?", "Readings?", "Estimate needed?", "Estimate set?", "Target?", "Current target?"]
      SchoolGroup.all.each do |school_group|
        service = Targets::SchoolGroupTargetDataReportService.new(school_group)
        data = service.report
        data.each do |school, result_data|
          result_data.each do |fuel_result_data|
            csv << [
              school_group.name,
              school.name,
              school.visible,
              fuel_result_data[:fuel_type],
              fuel_result_data[:holidays],
              fuel_result_data[:temperature],
              fuel_result_data[:readings],
              fuel_result_data[:estimate_needed],
              fuel_result_data[:estimate_set],
              fuel_result_data[:target],
              fuel_result_data[:current_target]
            ]
          end
        end
      end
    end
    puts "#{Time.zone.now} Finished enough-data report"
  end
end
