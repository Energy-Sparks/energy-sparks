namespace :loader do
  desc 'Load energy usage data for all schools'
  task read_meters: [:environment] do
    importer = Loader::EnergyImporter.new
    School.all.each do |school|
      importer.import_new_data_for(school)
    end
  end
end
