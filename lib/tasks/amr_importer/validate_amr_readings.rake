namespace :amr_importer do
  desc "Validate readings"
  task validate_readings: :environment do
    puts DateTime.now.utc
    puts "Total AMR Readings before: #{AmrReading.count}"
    School.enrolled.each do |school|
      AmrDataValidatorAndAggregatorService.new(school).persist_validated_amr_readings
    end
    puts "Total AMR Readings after: #{AmrReading.count}"
    puts DateTime.now.utc
  end
end
