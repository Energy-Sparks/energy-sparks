namespace :amr_importer do
  desc "Validate readings"
  task validate_amr_readings: :environment do
    puts DateTime.now.utc
    total_amr_readings_before = AmrValidatedReading.count
    puts "Total AMR Readings before: #{total_amr_readings_before}"

    School.all.each do |each_school|
      puts "Validate and persist for #{each_school.name}"
      Amr::ValidateAndPersistReadingsService.new(each_school).perform
      puts "Clear cache for #{each_school.name}"
      AggregateSchoolService.new(each_school).invalidate_cache
    end

    total_amr_readings_after = AmrValidatedReading.count
    puts "Total AMR Readings after: #{total_amr_readings_after} - inserted: #{total_amr_readings_after - total_amr_readings_before}"
    puts DateTime.now.utc
  end
end
