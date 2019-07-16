# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: create_new_data_feed_config_for_frome'
  task create_new_data_feed_config_for_frome: :environment do
    puts "Running deploy task 'Create new data feed config for frome'"

    # Put your task implementation HERE.
    ActiveRecord::Base.transaction do
      frome_wua = WeatherUndergroundArea.where(title: 'Frome').first_or_create
      frome_pva = SolarPvTuosArea.where(title: 'Frome').first_or_create

      frome_config = {
        name: 'Frome',
        latitude: 51.2308,
        longitude: -2.3201,
        start_date: Date.new(2013, 8, 12), # may be better in controlling program
        end_date: Date.new(2018, 9, 26), # ditto, inclusive
        method: :weighted_average,
        max_minutes_between_samples: 120, # ignore data where samples from station are too far apart
        max_temperature: 38.0,
        min_temperature: -15.0,
        solar_scale_factor: 1.0,
        max_solar_insolence: 2000.0,
        weather_stations_for_temperature:
        { # weight for averaging, selection: the weather station names are found by browsing weather underground local station data
          'IFROME9' => 0.25,
          'IFROME5' => 0.25,
          'IWARMINS4' => 0.1,
          'IWILTSHI36' => 0.1,
          'IRADSTOC7' => 0.1,
          'IKILMERS2' => 0.1,
          'IUPTONNO2' => 0.1
        },
        weather_stations_for_solar: # has to be a temperature station for the moment - saves loading twice
        {
          'IKILMERS2' => 0.5,
          'IUPTONNO2' => 0.5
        },
        temperature_csv_file_name: 'Frome temperaturedata.csv',
        solar_csv_file_name: 'Frome solardata.csv',
        csv_format: :landscape
      }

      wu = DataFeeds::WeatherUnderground.where(title: 'Weather Underground Frome', area: frome_wua).first_or_create
      wu.update(configuration: frome_config)

      frome_pv_config = {
        name: 'Frome',
        latitude: 51.2308,
        longitude: -2.3201,
        proxies: [
          { id: 152, name: 'Iron Acton', code: 'IROA', latitude: 51.56933, longitude: -2.47937 },
          { id: 198, name: 'Melksham', code: 'MELK', latitude: 51.39403, longitude: -2.14938 },
          { id: 253, name: 'Seabank', code: 'SEAB', latitude: 51.53663, longitude: -2.66869 }
        ]
      }

      pv = DataFeeds::SolarPvTuos.where(title: 'Solar PV Tuos Frome', area: frome_pva).first_or_create
      pv.update(configuration: frome_pv_config)

      AfterParty::TaskRecord.create version: '20181116112028'
    end
  end
end
