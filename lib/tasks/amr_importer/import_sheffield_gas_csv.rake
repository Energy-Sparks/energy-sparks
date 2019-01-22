namespace :amr_sheffield_gas do
  desc "Import data from csv"
  task import_csv: :environment do
    puts "#{DateTime.now.utc} AMR Sheffield Gas start"

    config = AmrDataFeedConfig.find_by(description: 'Sheffield Gas')
    FileUtils.mkdir_p config.local_bucket_path

    Amr::Importer.new(config).import_all
    puts "#{DateTime.now.utc} AMR Sheffield end"
  end
end
