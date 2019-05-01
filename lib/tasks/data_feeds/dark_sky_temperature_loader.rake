namespace :data_feeds do
  def process_area(area, start_date, end_date)
    data = DarkSkyWeatherInterface.new.historic_temperatures(
      area.latitude,
      area.longitude,
      start_date,
      end_date
    )

    # Data is returned as an array [[distance_to_weather_station, temperature_data, percent_bad, bad_data]
    temperature_data = data[1]

    temperature_data.each do |reading_date, temperature_celsius_x48|
      next if temperature_celsius_x48.size != 48
      record = DataFeeds::DarkSkyTemperatureReading.find_by(reading_date: reading_date, area_id: area.id)
      if record
        record.update(temperature_celsius_x48: temperature_celsius_x48)
      else
        DataFeeds::DarkSkyTemperatureReading.create(
          reading_date: reading_date,
          temperature_celsius_x48: temperature_celsius_x48,
          area_id: area.id
        )
      end
    end
  end

  desc 'Load dark sky temperature data'
  task :dark_sky_temperature_loader, [:start_date, :end_date] => :environment do |_t, args|
    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : Date.yesterday - 1
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday

    DarkSkyArea.all.each do |area|
      process_area(area, start_date, end_date)
    end
  end
end
