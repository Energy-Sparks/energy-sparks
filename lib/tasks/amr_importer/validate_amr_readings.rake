namespace :amr_importer do
  desc "Validate readings"
  task validate_readings: :environment do
    puts DateTime.now.utc
    total_amr_readings_before = AmrValidatedReading.count
    puts "Total AMR Readings before: #{total_amr_readings_before}"
    School.enrolled.each do |school|
      puts "Validate and persist for #{school.name}"
      Amr::ValidateAndPersistReadingsService.new(school).perform
    end
    total_amr_readings_after = AmrValidatedReading.count
    puts "Total AMR Readings after: #{total_amr_readings_after} - inserted: #{total_amr_readings_after - total_amr_readings_before}"
    puts DateTime.now.utc
  end
end
