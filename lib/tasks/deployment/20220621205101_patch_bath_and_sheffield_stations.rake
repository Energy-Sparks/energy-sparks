namespace :after_party do
  desc 'Deployment task: patch_bath_and_sheffield_stations'
  task patch_bath_and_sheffield_stations: :environment do
    puts 'Copy missing data between Bath and Sheffield stations'

    # Start Date: 2022-06-02
    # End Date: 2022-06-13

    # Bath
    # Dark Sky: 11
    # Meteostat: 6
    (Date.new(2022, 0o6, 0o2)..Date.new(2022, 0o6, 13)).each do |day|
      ds_reading = DarkSkyArea.find(11).dark_sky_temperature_readings.where(reading_date: day).first
      ws_reading = WeatherStation.find(6).weather_observations.where(reading_date: day).first
      if ds_reading.present? && ws_reading.present?
        ws_reading.update!(temperature_celsius_x48: ds_reading.temperature_celsius_x48)
      end
    end

    # Sheffield
    # Dark Sky: 12
    # Meteostat: 2
    (Date.new(2022, 0o6, 0o2)..Date.new(2022, 0o6, 13)).each do |day|
      ds_reading = DarkSkyArea.find(12).dark_sky_temperature_readings.where(reading_date: day).first
      ws_reading = WeatherStation.find(2).weather_observations.where(reading_date: day).first
      if ds_reading.present? && ws_reading.present?
        ws_reading.update!(temperature_celsius_x48: ds_reading.temperature_celsius_x48)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
