namespace :after_party do
  desc 'Deployment task: Create Meteostat stations based on DSA areas'
  task add_meteostat_stations: :environment do
    puts "Running deploy task 'add_meteostat_stations'"

    # Put your task implementation HERE.
    DarkSkyArea.all.each do |dsa|
      station = WeatherStation.find_by(title: dsa.title, latitude: dsa.latitude, longitude: dsa.longitude)
      if station.nil?
        WeatherStation.create!(
          title: dsa.title,
          description: "Copied from Dark Sky Area",
          provider: WeatherStation::METEOSTAT,
          latitude: dsa.latitude,
          longitude: dsa.longitude,
          back_fill_years: 0 #as we'll use the data from the dark sky area
        )
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
