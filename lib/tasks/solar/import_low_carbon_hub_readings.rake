namespace :solar do
  desc "Import low carbon hub data"
  task :import_low_carbon_hub_readings, [:start_date, :end_date] => :environment do |_t, args|

    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : nil
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : nil

    puts "#{DateTime.now.utc} import_low_carbon_hub_readings start"
    LowCarbonHubInstallation.all.each do |installation|
      puts "Running for #{installation.rbee_meter_id}"
      Solar::LowCarbonHubDownloadAndUpsert.new(installation: installation, start_date: start_date, end_date: end_date).perform
    end
    puts "#{DateTime.now.utc} import_low_carbon_hub_readings end"
  end
end
