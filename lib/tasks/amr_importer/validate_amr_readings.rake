namespace :amr_importer do
  desc "Validate readings"
  task validate_amr_readings: :environment do
    @schools = School.process_data
    @schools.each do |school|
      ValidateAndAggregateAmrReadingsJob.perform_later(school: school)
    end
  end
end
