namespace :loader do
  desc 'Load energy usage data for all schools'
  task read_meters: [:environment] do
    importer = Loader::EnergyImporter.new
    School.enrolled.each do |school|
      puts "Reading meters for #{school.urn} - #{school.name}"
      importer.import_new_data_for(school)
    end
  end
end
