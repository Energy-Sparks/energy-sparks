namespace :solar do
  desc "Import solar edge data"
  task :import_solar_edge_readings, [:start_date, :end_date] => :environment do |_t, args|

    default_start_date = Date.yesterday - 5
    requested_start_date =  Date.parse(args[:start_date]) if args[:start_date].present?

    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday

    SolarEdgeInstallation.all.each do |installation|
      puts "Running for #{installation.site_id}"

      start_date = if requested_start_date
                     requested_start_date
                   else
                     if installation.latest_electricity_reading
                       [installation.latest_electricity_reading, default_start_date].min
                     else
                       default_start_date
                     end
                   end

      Solar::SolarEdgeDownloadAndUpsert.new(solar_edge_installation: installation, start_date: start_date, end_date: end_date).perform
    end
  end
end
