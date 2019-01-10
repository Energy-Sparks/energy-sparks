namespace :amr_banes do
  desc "Import data from csv"
  task import_csv: :environment do
    puts "#{DateTime.now.utc} AMR BANES start"

    config = AmrDataFeedConfig.find_by(description: 'Banes')
    FileUtils.mkdir_p config.local_bucket_path

    Amr::Importer.new(config).import_all

    puts "#{DateTime.now.utc} AMR BANES end"
  end
end
