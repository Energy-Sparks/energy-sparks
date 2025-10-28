namespace :targets do
  desc 'Run report to targets feature'
  task test_targets: [:environment] do
    puts "#{Time.zone.now} Generating test-target report"
    if ENV['ENVIRONMENT_IDENTIFIER'] == "production"
      puts "Cannot run this report in this environment!"
    else
      CSV.open("/tmp/test-targets-report.csv", "w") do |csv|
        csv << ["Group", "School", "Fuel Type", "Enough data", "Recent data", "Success", "Progress", "Error"]
        SchoolGroup.organisation_groups.each do |school_group|
          service = Targets::SchoolGroupTargetsTestingService.new(school_group)
          test_result = service.report
          test_result.each do |school, report|
            report.each do |fuel_type, results|
              csv << [
                school_group.name,
                school.name,
                fuel_type,
                results[:enough_data],
                results[:recent_data],
                results[:success],
                results[:progress],
                results[:error],
              ]
            end
          end
        end
      end
    end
    puts "#{Time.zone.now} Finished test-target report"
  end
end
