namespace :amr_frome_historical do
  desc "Import data from csv"
  task import_csv: :environment do
    puts "#{DateTime.now.utc} AMR Frome Historical start"

    config = AmrDataFeedConfig.find_by(description: 'Frome Historical')
    FileUtils.mkdir_p config.local_bucket_path

    Amr::Importer.new(config).import_all
    puts "#{DateTime.now.utc} AMR Frome Historical end"
  end
end
