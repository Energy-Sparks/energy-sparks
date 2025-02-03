namespace :amr_importer do
  desc "Validate readings"
  task validate_amr_readings: :environment do
    puts "#{DateTime.now.utc} Validate AMR readings start"
    total_amr_readings_before = AmrValidatedReading.count
    puts "Total AMR Readings before: #{total_amr_readings_before}"

    School.process_data.each do |each_school|
      puts "Validate and persist for #{each_school.name}"
      begin
        Amr::ValidateAndPersistReadingsService.new(each_school).perform
        puts "Clear cache for #{each_school.name}"
        AggregateSchoolService.new(each_school).invalidate_cache
      rescue => e
        puts "Exception: running validation for #{each_school.name}: #{e.class} #{e.message}"
        puts e.backtrace.join("\n")
        Rails.logger.error "Exception: running validation for #{each_school.name}: #{e.class} #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        Rollbar.error(e, job: :validate_amr_readings, school_id: each_school.id, school: each_school.name)
      end
    end

    total_amr_readings_after = AmrValidatedReading.count
    puts "Total AMR Readings after: #{total_amr_readings_after} - inserted: #{total_amr_readings_after - total_amr_readings_before}"
    puts "#{DateTime.now.utc} Validate AMR readings end"
  end
end
