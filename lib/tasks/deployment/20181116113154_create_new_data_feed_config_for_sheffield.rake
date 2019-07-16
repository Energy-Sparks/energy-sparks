# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: create_new_data_feed_config_for_sheffield'
  task create_new_data_feed_config_for_sheffield: :environment do
    puts "Running deploy task 'Create new data feed config for Sheffield'"

    # Put your task implementation HERE.
    ActiveRecord::Base.transaction do
      wua = WeatherUndergroundArea.where(title: 'Sheffield').first_or_create
      pva = SolarPvTuosArea.where(title: 'Sheffield').first_or_create

      config = {
        name: 'Sheffield',
        latitude: 53.3811,
        longitude: -1.4701,
        start_date: Date.new(2013, 1, 1), # may be better in controlling program
        end_date: Date.new(2018, 9, 25), # ditto, inclusive
        method: :weighted_average,
        max_minutes_between_samples: 120, # ignore data where samples from station are too far apart
        max_temperature: 38.0,
        min_temperature: -15.0,
        solar_scale_factor: 1.32,
        max_solar_insolence: 2000.0,
        weather_stations_for_temperature:
        { # weight for averaging, selection: the weather station names are found by browsing weather underground local station data
          'ISHEFFIE84' => 0.1,
          'ISHEFFIE18' => 0.25,
          'ISOUTHYO31' => 0.3,
          'ISOUTHYO29' => 0.1,
          'ISHEFFIE56' => 0.25
        },
        weather_stations_for_solar: # has to be a temperature station for the moment - saves loading twice
        {
          'ISHEFFIE18' => 0.33,
          'ISOUTHYO31' => 0.33,
          'ISHEFFIE56' => 0.33
        },
        temperature_csv_file_name: 'Sheffield temperaturedata.csv',
        solar_csv_file_name: 'Sheffield solardata.csv',
        csv_format: :landscape
      }

      wu = DataFeeds::WeatherUnderground.where(title: 'Weather Underground Sheffield', area: wua).first_or_create
      wu.update(configuration: config)

      pv_config = {
        name: 'Sheffield',
        latitude: 53.3811,
        longitude: -1.4701,
        proxies: [
          { id: 257, name: 'Sheffield City', code: 'SHEC', latitude: 53.37445, longitude: -1.47708 },
          { id: 207, name: 'Neepsend', code: 'NEEP', latitude: 53.40642, longitude: -1.48696 },
          { id: 213, name: 'Norton Lees', code: 'NORL', latitude: 53.34823, longitude: -1.46998 }
        ]
      }

      pv = DataFeeds::SolarPvTuos.where(title: 'Solar PV Tuos Sheffield', area: pva).first_or_create
      pv.update(configuration: pv_config)

      AfterParty::TaskRecord.create version: '20181116113154'
    end
  end
end
