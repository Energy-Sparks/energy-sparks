namespace :solar do
  desc "Import low carbon hub data"
  task :import_low_carbon_hub_readings, [:start_date, :end_date] => :environment do |_t, args|

    default_start_date = Date.yesterday - 5
    requested_start_date =  Date.parse(args[:start_date]) if args[:start_date].present?

    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday

    LowCarbonHubInstallation.all.each do |installation|
      puts "Running for #{installation.rbee_meter_id}"

      start_date = if requested_start_date
                     requested_start_date
                   else
                     installation.latest_electricity_reading < default_start_date ? installation.latest_electricity_reading : default_start_date
                   end

      Solar::LowCarbonHubDownloadAndUpsert.new(low_carbon_hub_installation: installation, start_date: start_date, end_date: end_date).perform
    end
  end
end
