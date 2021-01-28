require 'dashboard'

module DataFeeds
  class MeteostatLoader
    attr_reader :insert_count, :update_count, :stations_processed

    def initialize(start_date = Date.yesterday - 8.days, end_date = Date.yesterday, meteostat_interface = MeteoStat.new)
      @start_date = start_date
      @end_date = end_date
      @meteostat_interface = meteostat_interface
      @insert_count = 0
      @update_count = 0
      @stations_processed = 0
    end

    def import
      WeatherStation.active_by_provider(WeatherStation::METEOSTAT).each do |station|
        import_station(station)
      end
    end

    def import_station(station)
      process_station(station)
      @stations_processed = @stations_processed + 1
    end

    private

    def process_station(station)
      begin
        results = @meteostat_interface.historic_temperatures(station.latitude, station.longitude, @start_date, @end_date)
        results[:temperatures].each do |reading_date, temperature_celsius_x48|
          next if temperature_celsius_x48.size != 48
          process_day(reading_date, temperature_celsius_x48, station)
        end
      rescue => e
        Rails.logger.error "Exception: running station import for #{station.title} from #{@start_date} to #{@end_date} : #{e.class} #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        Rollbar.error(e)
      end
    end

    def process_day(reading_date, temperature_celsius_x48, station)
      record = WeatherObservation.find_by(reading_date: reading_date, weather_station: station)
      if record
        record.update(temperature_celsius_x48: temperature_celsius_x48)
        @update_count = @update_count + 1
      else
        WeatherObservation.create(
          weather_station: station,
          reading_date: reading_date,
          temperature_celsius_x48: temperature_celsius_x48
        )
        @insert_count = @insert_count + 1
      end
    end
  end
end
