namespace :loader do
  desc 'Load energy usage data for all schools'
  task read_meters: [:environment] do
    puts Time.zone.now
    importer = Loader::EnergyImporter.new
    School.enrolled.each do |school|
      puts "Reading meters for #{school.urn} - #{school.name}"
      importer.import_new_data_for(school)
    end
    puts Time.zone.now
  end

  task :import_school_readings, [:date] => [:environment] do |_t, args|
    since_date = Date.parse(args[:date])
    importer = Loader::EnergyImporter.new
    School.enrolled.each do |school|
      next if school.meter_readings.any?
      puts "Reading meters for #{school.urn} - #{school.name}"
      importer.import_all_data_for(school, since_date)
    end
  end

  desc 'Load schools csv[:file_path]'
  task :import_schools, [:file_path] => [:environment] do |_t, args|
    Loader::Schools.load!(args[:file_path])
  end

  desc 'Load activities csv[:file_path]'
  task :import_activities, [:file_path] => [:environment] do |_t, args|
    Loader::Activities.load!(args[:file_path])
  end

  desc 'Load activity progression csv[:file_path]'
  task :import_activity_progression, [:file_path] => [:environment] do |_t, args|
    Loader::Activities.load_progression!(args[:file_path])
  end

end
