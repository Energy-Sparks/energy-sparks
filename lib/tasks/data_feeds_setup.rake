namespace :data_feeds do
  desc 'Set up data feeds'
  task setup: [:environment] do
    WeatherUndergroundArea.delete_all
    DataFeeds::WeatherUnderground.delete_all

    wua = WeatherUndergroundArea.where(title: 'Bath').first_or_create
    pp wua.class

   bath_config = {
    # TODO - switch to symbols and Ruby 1.9 hash format
    # weight for averaging, selection: the weather station names are found by browsing weather underground local station data

    weather_stations_for_temperature:
      { # weight for averaging, selection: the weather station names are found by browsing weather underground local station data
        'ISOMERSE15'  => 0.5,
        'IBRISTOL11'  => 0.2,
        'ISOUTHGL2'   => 0.1,
        'IENGLAND120' => 0.1,
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
      solar_csv_file_name: 'bathsolardata.csv',
    }

    DataFeeds::WeatherUnderground.where(title: 'Weather Underground', area: wua, configuration: bath_config).first_or_create
  end
end
