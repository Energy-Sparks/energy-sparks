namespace :solar do
  desc "Import solar edge data"
  task :import_solar_edge_readings, [:start_date, :end_date] => :environment do |_t, args|

    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : nil
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : nil

    puts "#{DateTime.now.utc} import_solar_edge_readings start"
    begin
      SolarEdgeInstallation.all.each do |installation|
        puts "Running for #{installation.school.name} #{installation.site_id}"
        Solar::SolarEdgeDownloadAndUpsert.new(installation: installation, start_date: start_date, end_date: end_date).perform
      end
    rescue => e
      puts "Exception: importing readings #{e.class} #{e.message}"
      puts e.backtrace.join("\n")
      Rails.logger.error "Exception: importing readings: #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :import_solar_edge_readings)
    end
    puts "#{DateTime.now.utc} import_solar_edge_readings end"
  end
end
