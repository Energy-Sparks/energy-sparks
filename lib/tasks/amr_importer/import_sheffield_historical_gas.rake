namespace :amr_sheffield_historical_gas do
  desc "Import data from csv"
  task import_csv: :environment do
    description = 'Sheffield Historical Gas'
    puts "#{DateTime.now.utc} AMR #{description} Sheffield Historical Gas start"

    config = AmrDataFeedConfig.find_by(description: description)
    FileUtils.mkdir_p config.local_bucket_path

    Amr::Importer.new(config).import_all
    puts "#{DateTime.now.utc} AMR Sheffield end"
  end
end
