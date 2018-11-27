namespace :amr_importer do
  desc "Validate readings"
  task :validate_readings_by_school_group_name, [:school_group_description] => :environment do |_t, args|
    puts DateTime.now.utc
    total_amr_readings_before = AmrValidatedReading.count
    puts "Total AMR Readings before: #{total_amr_readings_before}"

    school_group_description = args[:school_group_description]
    raise ArgumentError, 'Region description not set, should be, Bath, Frome, Sheffield for example' if school_group_description.nil?

    school_group = SchoolGroup.where('name LIKE ?', "%#{school_group_description}%").first
    raise ArgumentError, "Can't find school group for #{school_group_description}" if school_group.nil?

    School.where(school_group: school_group).each do |each_school|
      puts "Validate and persist for #{each_school.name}"
      Amr::ValidateAndPersistReadingsService.new(each_school).perform
    end

    total_amr_readings_after = AmrValidatedReading.count
    puts "Total AMR Readings after: #{total_amr_readings_after} - inserted: #{total_amr_readings_after - total_amr_readings_before}"
    puts DateTime.now.utc
  end
end
