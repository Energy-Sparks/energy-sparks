require 'dashboard'

module DataFeeds
  class DarkSkyTemperatureLoader
    # DarkSky FAQ recommends getting the last 10 days worth of data for consolidation purposes, some weather stations take a while
    # to push their data
    def initialize(start_date = Date.yesterday - 10.days, end_date = Date.yesterday, dark_sky_api_interface = DarkSkyWeatherInterface.new)
      @start_date = start_date
      @end_date = end_date
      @dark_sky_api_interface = dark_sky_api_interface
      @insert_count = 0
      @update_count = 0
    end

    def import
      DarkSkyArea.all.each do |area|
        process_area(area)
      end
      p "Imported #{@insert_count} records, Updated #{@update_count} records"
    end

    def import_area(area)
      process_area(area)
      p "Imported #{@insert_count} records, Updated #{@update_count} records"
    end

  private

    def process_area(area)
      data = @dark_sky_api_interface.historic_temperatures(
        area.latitude,
        area.longitude,
        @start_date,
        @end_date
      )

      # Data is returned as an array [[distance_to_weather_station, temperature_data, percent_bad, bad_data]
      temperature_data = data[1]

      temperature_data.each do |reading_date, temperature_celsius_x48|
        next if temperature_celsius_x48.size != 48
        process_day(reading_date, temperature_celsius_x48, area)
      end
    end

    def process_day(reading_date, temperature_celsius_x48, area)
      pp "Processing #{reading_date}"
      record = DarkSkyTemperatureReading.find_by(reading_date: reading_date, area_id: area.id)
      if record
        record.update(temperature_celsius_x48: temperature_celsius_x48)
        @update_count = @update_count + 1
      else
        DarkSkyTemperatureReading.create(
          reading_date: reading_date,
          temperature_celsius_x48: temperature_celsius_x48,
          area_id: area.id
        )
        @insert_count = @insert_count + 1
      end
    end
  end
end
