namespace :amr do
  desc 'Import data from csv'
  task import_all: :environment do
    puts "#{DateTime.now.utc} amr import all start"
    AmrDataFeedConfig.s3_folder.each do |config|
      AmrImportJob.import_all(config)
    rescue StandardError => e
      EnergySparks::Log.exception(e, job: :import_all, config: config.identifier)
    end
    puts "#{DateTime.now.utc} amr import all end"
  end
end
