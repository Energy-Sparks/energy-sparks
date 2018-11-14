namespace :amr_frome do
  desc "Import data from csv"
  task import_csv: :environment do
    puts "#{DateTime.now.utc} AMR Frome start"

    config = AmrDataFeedConfig.find_by(description: 'Frome')
    FileUtils.mkdir_p config.local_bucket_path

    Amr::Importer.new(config).import_all
    puts "#{DateTime.now.utc} AMR Frome end"
  end
end
