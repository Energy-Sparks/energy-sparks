namespace :data_feeds do
  desc 'Load dark sky temperature data'
  task :dark_sky_temperature_loader, [:start_date, :end_date] => :environment do |_t, args|
    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : Date.yesterday - 1
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday

    AREAS = {
      bath:       { latitude: 51.39,   longitude: -2.37 },
      sheffield:  { latitude: 53.3811, longitude: -1.4701 },
      frome:      { latitude: 51.2308, longitude: -2.3201 },
    }.freeze

    area = AREAS[:bath]

    data = DarkSkyWeatherInterface.new.historic_weather(
      area[:latitude],
      area[:longitude],
      start_date,
      end_date
    )

    # Data is returned as an array [[distance_to_weather_station, temperature_data, percent_bad, bad_data]
    temperature_data = data[1]

    temperature_data.each do |reading_date, temperature_celsius_x48|
      next if temperature_celsius_x48.size != 48
      record = DataFeeds::DarkSkyTemperatureReading.find_by(reading_date: reading_date)
      if record
        record.update(temperature_celsius_x48: temperature_celsius_x48)
      else
        DataFeeds::DarkSkyTemperatureReading.create(
          reading_date: reading_date,
          temperature_celsius_x48: temperature_celsius_x48
        )
      end
    end
  end
end
