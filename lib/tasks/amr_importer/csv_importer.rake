namespace :amr_importer do
  desc "Import data from csv"
  task import_csv: :environment do
    puts "Make sure Banes set up"
    puts DateTime.now.utc
    banes_config = AmrDataFeedConfig.set_up_banes

    file_name = '02-10-2018-last30days.csv'
    importer = CsvImporter.new(banes_config, file_name)
    importer.parse

    puts "imported"
    puts DateTime.now.utc
  end
end
