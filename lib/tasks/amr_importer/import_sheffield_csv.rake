namespace :amr_sheffield do
  desc "Import data from csv"
  task :import_csv, [:readings_date] => :environment do |_t, args|
    puts "Import Sheffield AMR for #{readings_date}"
    puts DateTime.now.utc

    config = AmrDataFeedConfig.find_by(description: 'Sheffield')
    FileUtils.mkdir_p config.local_bucket_path

    readings_date = args[:readings_date] ? DateTime.parse(args[:readings_date]).utc.strftime('%Y%m%d') : DateTime.yesterday.strftime('%d-%m-%Y')

    # 4003063_9232_Export_20181104_120347_747
    file_name = "4003063_9232_Export_#{readings_date}.csv"

    Amr::Importer.new(readings_date, config, file_name).import
    puts DateTime.now.utc
  end
end
