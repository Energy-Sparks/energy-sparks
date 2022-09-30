namespace :amr_importer do
  desc "Validate readings"
  task validate_amr_readings: :environment do
    School.process_data.each do |school|
      ValidateAndAggregateAmrReadingsJob.perform_later(school)
    end
  end
end
