namespace :amr_banes do
  desc "Import data from csv"
  task :import_csv, [:readings_date] => :environment do |_t, args|
    readings_date = args[:readings_date] ? DateTime.parse(args[:readings_date]).utc.strftime('%Y%m%d') : DateTime.yesterday.strftime('%d-%m-%Y')

    puts "Import BANES AMR for #{readings_date}"
    puts DateTime.now.utc

    config = AmrDataFeedConfig.find_by(description: 'Banes')
    FileUtils.mkdir_p config.local_bucket_path
    file_name = "30days-#{readings_date}.csv"

    Amr::Importer.new(readings_date, config, file_name).import
    puts DateTime.now.utc
  end
end
