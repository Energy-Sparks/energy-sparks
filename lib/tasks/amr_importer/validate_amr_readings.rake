namespace :amr_importer do
  desc "Validate readings"
  task validate_amr_readings: :environment do
    @schools = School.process_data
    @schools.each do |school|
      ValidateAndAggregateAmrReadingsJob.perform_later(
        school: school,
        send_metrics_after_perform: school == @schools.last
      )
    end
  end
end
