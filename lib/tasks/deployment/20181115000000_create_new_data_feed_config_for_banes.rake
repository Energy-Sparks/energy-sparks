namespace :after_party do
  desc 'Deployment task: create_new_data_feed_config_for_banes'
  task create_new_data_feed_config_for_banes: :environment do
    puts "Running deploy task 'create_new_data_feed_config_for_banes'"

    # Put your task implementation HERE.
    wua = WeatherUndergroundArea.where(title: 'Bath').first_or_create
    pva = SolarPvTuosArea.where(title: 'Bath').first_or_create

    bath_config = {
      # TODO - switch to symbols and Ruby 1.9 hash format
      # weight for averaging, selection: the weather station names are found by browsing weather underground local station data
      name: 'Bath',
      max_minutes_between_samples: 120, # ignore data where samples from station are too far apart
      weather_stations_for_temperature:
        { # weight for averaging, selection: the weather station names are found by browsing weather underground local station data
          'ISOMERSE15'  => 0.5,
          'IBRISTOL11'  => 0.2,
          'ISOUTHGL2'   => 0.1,
      #   'IENGLAND120' => 0.1,
          'IBATH9'      => 0.1,
          'IBASTWER2'   => 0.1,
          'ISWAINSW2'   => 0.1,
          'IBASMIDF2'   => 0.1
        },
        weather_stations_for_solar: # has to be a temperature station for the moment - saves loading twice
        {
          'ISOMERSE15' => 0.5
        },
        temperature_csv_file_name: 'bathtemperaturedata.csv',
        solar_csv_file_name: 'bathsolar_insolencedata.csv',
        csv_format: :portrait
      }

    wu = DataFeeds::WeatherUnderground.where(title: 'Weather Underground Bath', area: wua).first_or_create
    wu.update(configuration: bath_config)

    bath_pv_config = {
      name: 'Bath',
      latitude: 51.39,
      longitude: -2.37,
      proxies: [
                  { id: 152, name: 'Iron Acton', code: 'IROA', latitude: 51.56933, longitude: -2.47937 },
                  { id: 198, name: 'Melksham', code: 'MELK', latitude: 51.39403, longitude: -2.14938 },
                  { id: 253, name: 'Seabank', code: 'SEAB', latitude: 51.53663, longitude: -2.66869 }
                ]
    }

    pv = DataFeeds::SolarPvTuos.where(title: 'Solar PV Tuos Bath', area: pva).first_or_create
    pv.update(configuration: bath_pv_config)
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20181115000000'
  end
end
