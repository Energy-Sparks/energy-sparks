namespace :amr do
  desc 'Import data from csv'
  task import_all: :environment do
    puts "#{DateTime.now.utc} amr import all start"
    AmrDataFeedConfig.s3_folder.each do |config|
      AmrImportJob.import_all(config, ENV.fetch('AWS_S3_AMR_DATA_FEEDS_BUCKET'))
    rescue StandardError => e
      puts "Exception: running import_all for #{config.description}: #{e.class} #{e.message}"
      puts e.backtrace.join("\n")
      Rails.logger.error "Exception: running import_all for #{config.description}: #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :import_all, config: config.identifier)
    end
    puts "#{DateTime.now.utc} amr import all end"
  end
end
