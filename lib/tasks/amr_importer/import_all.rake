namespace :amr do
  desc 'Import data from csv'
  task import_all: :environment do
    puts "#{DateTime.now.utc} amr import all start"
    AmrDataFeedConfig.s3_folder.each do |config|
      FileUtils.mkdir_p config.local_bucket_path
      Amr::Importer.new(config).import_all
    rescue StandardError => e
      puts "Exception: running import_all for #{config.description}: #{e.class} #{e.message}"
      puts e.backtrace.join("\n")
      Rails.logger.error "Exception: running import_all for #{config.description}: #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :import_all, config: config.identifier)
    end
    Database::VacuumService.new([:amr_data_feed_readings]).perform
    puts "#{DateTime.now.utc} amr import all end"
  end
end
