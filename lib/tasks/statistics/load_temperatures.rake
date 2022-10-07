namespace :statistics do
  desc "Get benchmarks for temperature data loads"
  task load_temperatures: :environment do
    weather_settings = School.all.map { |school| { dark_sky_area_id: school.dark_sky_area_id, weather_station_id: school.weather_station_id } }.uniq
    benchmarks = [] # Store all benchmark data for later output to csv
    weather_settings.each do |weather_ids|
      weather_station_id = weather_ids[:weather_station_id]
      dark_sky_area_id = weather_ids[:dark_sky_area_id]
      weather_station_title = weather_station_id ? WeatherStation.find(weather_station_id)&.title : 'none'
      dark_sky_area_title = dark_sky_area_id ? DarkSkyArea.find(dark_sky_area_id)&.title : 'none'

      cache_key = if weather_station_id && dark_sky_area_id
                    "#{weather_station_id}-#{dark_sky_area_id}-dark-sky-temperatures-test"
                  elsif weather_station_id && dark_sky_area_id.nil?
                    "#{weather_station_id}-temperatures-test"
                  elsif dark_sky_area_id && weather_station_id.nil?
                    "#{dark_sky_area_id}-dark-sky-temperatures-test"
                  end

      puts "\nBenchmark for weather_station: #{weather_station_title} (#{weather_station_id || 'nil'}) and dark_sky_area: #{dark_sky_area_title} (#{dark_sky_area_id || 'nil'})"

      temperatures = Temperatures.new('temperatures')

      benchmark_measure = Benchmark.measure {
        Rails.cache.fetch(cache_key, expires_in: 3.hours) do
          # Load meteostat readings
          earliest = nil
          WeatherObservation.where(weather_station_id: weather_station_id).pluck(:reading_date, :temperature_celsius_x48).each do |date, values|
            if earliest.nil?
              earliest = date
            elsif date < earliest
              earliest = date
            end
            temperatures.add(date, values.map(&:to_f))
          end
          if dark_sky_area_id.present?
            if earliest.present?
              DataFeeds::DarkSkyTemperatureReading.where("area_id = ? AND reading_date < ?", dark_sky_area_id, earliest).pluck(:reading_date, :temperature_celsius_x48).each do |date, values|
                temperatures.add(date, values.map(&:to_f))
              end
            else
              DataFeeds::DarkSkyTemperatureReading.where(area_id: dark_sky_area_id).pluck(:reading_date, :temperature_celsius_x48).each do |date, values|
                temperatures.add(date, values.map(&:to_f))
              end
            end
          end
        end
      }
      puts benchmark_measure
      puts temperatures.inspect

      benchmarks << [
        weather_station_id,
        weather_station_title,
        dark_sky_area_id,
        dark_sky_area_title,
        benchmark_measure.real
        # ,measure.cstime,
        # measure.cutime,
        # measure.stime,
        # measure.utime,
        # measure.total
      ]
    end

    require 'csv'
    CSV.open("weather_benchmarks.csv", "w") do |csv|
      csv << ['weather_station_id', 'weather_station_title', 'dark_sky_area_id', 'dark_sky_area_title', 'elapsed_real_time']
      benchmarks.each { |row| csv << row }
    end
  end
end
