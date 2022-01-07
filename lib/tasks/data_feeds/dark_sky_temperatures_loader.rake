namespace :data_feeds do
  desc 'Load dark sky temperature data'
  task :dark_sky_temperature_loader, [:start_date, :end_date] => :environment do |_t, args|
    puts "#{DateTime.now.utc} dark_sky_temperature_loader start"
    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : Date.yesterday - 1
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday

    DataFeeds::DarkSkyTemperatureLoader.new(start_date, end_date).import
    puts "#{DateTime.now.utc} dark_sky_temperature_loader end"
  end
end
