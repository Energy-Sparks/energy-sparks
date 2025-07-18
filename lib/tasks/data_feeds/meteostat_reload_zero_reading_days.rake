namespace :data_feeds do
  desc 'Reload Meteostat data where days in period have zero temperature readings'
  task :meteostat_reload_zero_reading_days, [:start_date, :end_date] => :environment do |_t, args|
    puts "#{DateTime.now.utc} meteostat_reload_zero_reading_days start"

    start_date = args[:start_date]
    end_date = args[:end_date]

    abort("Provide start and end dates") unless start_date.present? && end_date.present?

    to_reload = WeatherStation.all.select do |station|
      # check to see if we have any 0.0 temperature readings between affected dates
      # zero might be fine during winter, but we've found dates where imported readings were
      # mostly zeroes during summer/autumn period
      station.weather_observations.between(start_date, end_date).any_zero_readings.any?
    end

    # Create loader to import during affected period
    loader = DataFeeds::MeteostatLoader.new(start_date, end_date)
    to_reload.each do |station|
      puts "Reloading #{station.title}"
      loader.import_station(station)
    end

    puts "#{DateTime.now.utc} meteostat_reload_zero_reading_days end"
  end
end
