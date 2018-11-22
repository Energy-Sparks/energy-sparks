namespace :loader do
  desc 'Load energy usage data for all schools'
  task read_meters: [:environment] do
    puts Time.zone.now
    importer = Loader::EnergyImporter.new
    School.all.each do |school|
      puts "Reading meters for #{school.urn} - #{school.name}"
      importer.import_new_data_for(school)
    end
    puts Time.zone.now
  end

  task :import_school_readings, [:date] => [:environment] do |_t, args|
    since_date = Date.parse(args[:date])
    importer = Loader::EnergyImporter.new
    School.all.each do |school|
      next if school.meter_readings.any?
      puts "Reading meters for #{school.urn} - #{school.name}"
      importer.import_all_data_for(school, since_date)
    end
  end

  desc 'Import data for a single meter'
  task :import_meter, [:meter_no, :date] => [:environment] do |_t, args|
    since_date = Date.parse(args[:date])
    meter = Meter.find_by_meter_no(args[:meter_no])
    importer = Loader::EnergyImporter.new
    importer.import_new_meter(meter, since_date)
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
