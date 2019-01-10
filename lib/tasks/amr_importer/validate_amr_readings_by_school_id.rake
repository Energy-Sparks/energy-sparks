namespace :amr_importer do
  desc "Validate readings"
  task :validate_amr_readings_by_school_id, [:school_id] => :environment do |_t, args|
    puts DateTime.now.utc
    total_amr_readings_before = AmrValidatedReading.count
    puts "Total AMR Readings before: #{total_amr_readings_before}"

    school_id = args[:school_id]
    raise ArgumentError, 'School id not set' if school_id.nil?

    school = School.find(school_id)

    puts "Validate and persist for #{school.name} only"
    Amr::ValidateAndPersistReadingsService.new(school).perform

    total_amr_readings_after = AmrValidatedReading.count
    puts "Total AMR Readings after: #{total_amr_readings_after} - inserted: #{total_amr_readings_after - total_amr_readings_before}"
    puts DateTime.now.utc
  end
end
