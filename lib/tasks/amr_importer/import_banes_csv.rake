namespace :amr_importer do
  desc "Import data from csv"
  task :import_csv, [:readings_date] => :environment do |_t, args|
    puts "Make sure Banes set up"
    puts DateTime.now.utc
    # Set this up, just in case it isn't already
    banes_config = AmrDataFeedConfig.set_up_banes

    readings_date = args[:readings_date] || DateTime.yesterday.strftime('%d-%m-%Y')
    file_name = "30days-#{readings_date}.csv"
    importer = CsvImporter.new(banes_config, file_name)
    importer.parse

    puts "imported"
    puts DateTime.now.utc
  end
end
