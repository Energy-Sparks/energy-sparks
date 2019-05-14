namespace :amr do
  desc "Import data from csv"
  task import_all: :environment do
    AmrDataFeedConfig.all.each do |config|
      puts "#{DateTime.now.utc} #{config.description} start"

      FileUtils.mkdir_p config.local_bucket_path
      Amr::Importer.new(config).import_all

      puts "#{DateTime.now.utc} #{config.description} end"
    end
  end
end
