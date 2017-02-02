namespace :loader do
  desc 'Load energy usage data for all schools'
  task read_meters: [:environment] do
    importer = Loader::EnergyImporter.new
    School.enrolled.each do |school|
      puts "Reading meters for #{school.urn} - #{school.name}"
      importer.import_new_data_for(school)
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
end
