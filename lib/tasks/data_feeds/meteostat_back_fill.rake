namespace :data_feeds do
  desc 'Backfill meteostat data'
  task meteostat_back_fill: :environment do

    MINIMUM_READINGS_PER_YEAR = 365

    WeatherStation.active_by_provider(WeatherStation::METEOSTAT).each do |station|

      unless station.has_sufficient_readings?(Date.yesterday, MINIMUM_READINGS_PER_YEAR)

        station.back_fill_years.times.each do |year_number|
          # End date
          # Year 0 - Date Today
          # Year 1 - Date Today - 1 year
          # Year 2 - Date Today - 2 year
          # Year 3 - Date Today - 3 year
          end_date = Date.yesterday - (year_number * MINIMUM_READINGS_PER_YEAR)
          start_date = end_date - MINIMUM_READINGS_PER_YEAR.days

          p "Running #{station.title} for #{start_date} - #{end_date}"

          DataFeeds::MeteostatLoader.new(start_date, end_date).import_station(station)

          break if station.has_sufficient_readings?(Date.yesterday, MINIMUM_READINGS_PER_YEAR)

        end
      end
    end
  end
end
