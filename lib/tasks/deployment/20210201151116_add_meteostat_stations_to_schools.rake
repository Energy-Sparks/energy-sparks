namespace :after_party do
  desc 'Deployment task: Add stations to schools'
  task add_meteostat_stations_to_schools: :environment do
    puts "Running deploy task 'add_meteostat_stations_to_schools'"

    # Put your task implementation HERE.
    DarkSkyArea.all.each do |dsa|
      station = WeatherStation.find_by(title: dsa.title, latitude: dsa.latitude, longitude: dsa.longitude)
      if station.present?
        #loop schools, add station
        School.where(dark_sky_area: dsa).each do |school|
          school.weather_station = station
          school.save!
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
