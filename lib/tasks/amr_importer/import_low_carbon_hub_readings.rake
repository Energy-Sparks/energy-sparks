namespace :amr do
  desc "Import low carbon hub data"
  task :import_low_carbon_hub_readings, [:start_date, :end_date] => :environment do |_t, args|
    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : Date.yesterday - 5
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday

    amr_data_feed_config = AmrDataFeedConfig.find_by(description: 'Low carbon hub', access_type: 'API')

    LowCarbonHubInstallation.all.each do |installation|
      puts "Running for #{installation.rbee_meter_id}"

      Amr::LowCarbonHubDownloadAndUpsert.new(low_carbon_hub_installation: installation, amr_data_feed_config: amr_data_feed_config, start_date: start_date, end_date: end_date).perform
    end
  end
end
