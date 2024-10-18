# frozen_string_literal: true

require 'net/http'
require 'date'
require 'time'
require 'amazing_print'
require 'interpolate'
require 'tzinfo'

module DataFeeds
  class MeteoStat
    DAYS_PER_REQUEST = 30
    DEFAULT_ALTITUDE = 30.0
    DEFAULT_RADIUS_METERS = 100_000
    SEARCH_LIMIT = 8

    def initialize(api_key = ENV.fetch('ENERGYSPARKSMETEOSTATAPIKEY', nil))
      @api_key = api_key
      @schools_timezone = TZInfo::Timezone.get('Europe/London')
    end

    # returns a hash, with 2 entries
    # - [:temperatures] => { Date => [ float x 48 ]
    # - [:missing]      => [ Time ]
    def historic_temperatures(latitude, longitude, start_date, end_date, altitude = DEFAULT_ALTITUDE)
      raw_data = download(latitude, longitude, start_date, end_date, altitude)
      convert_to_datetime_to_x48(raw_data, start_date, end_date)
    end

    def nearest_weather_stations(latitude, longitude, number_of_results = SEARCH_LIMIT,
                                 within_radius_meters = DEFAULT_RADIUS_METERS)
      download_nearby_stations(latitude, longitude, number_of_results, within_radius_meters)
    end

    private

    def download(latitude, longitude, start_date, end_date, altitude)
      datetime_to_temperature = []
      (start_date..end_date).to_a.each_slice(DAYS_PER_REQUEST).each do |dates|
        raw_data = download_historic_data(latitude, longitude, dates.first, dates.last, altitude)
        datetime_to_temperature += raw_data['data'].map { |reading| parse_temperature_reading(reading) }
      end
      datetime_to_temperature.to_h
    end

    # Interpolates to half-hourly data from hourly readings
    # Also interpolates missing days from the data available in the response
    def convert_to_datetime_to_x48(temperatures, start_date, end_date)
      interpolator = Interpolate::Points.new(convert_weather_data_for_interpolation(temperatures))
      dated_temperatures = {}
      missing = []
      (start_date..end_date).each do |date|
        dated_temperatures[date] = []
        (0..23).each do |hour|
          # NOTE: we're creating date in default timezone here, should probably have
          # an explicit timezone here
          dt = Time.zone.local(date.year, date.month, date.day, hour, 0, 0)
          missing.push(dt) unless temperatures.key?(dt) && time_exists?(dt)
          [0, 30].freeze.each do |halfhour|
            t = Time.zone.local(date.year, date.month, date.day, hour, halfhour, 0)
            dated_temperatures[date].push(interpolator.at(t.to_i).round(2))
          end
        end
      end
      { temperatures: dated_temperatures, missing: }
    end

    # get missing data for March/Spring clocks going forward
    # at 1pm, test for and don't add to missing data
    #
    # this interface currently doesn't work - seems Meteostat
    # and TZInfo disagree slightly on when the clocks go forward
    def time_exists?(datetime)
      @schools_timezone.utc_to_local(datetime)
      true
    rescue TZInfo::PeriodNotFound => _e
      false
    end

    def convert_weather_data_for_interpolation(temperatures)
      temperatures.transform_keys(&:to_i)
    end

    def download_historic_data(latitude, longitude, start_date, end_date, altitude)
      meteostat_api.historic_temperatures(latitude, longitude, start_date, end_date, altitude)
    end

    def download_nearby_stations(latitude, longitude, number_of_results, within_radius_meters)
      stations = meteostat_api.nearby_stations(latitude, longitude, number_of_results, within_radius_meters)
      if stations['data']
        stations['data'].map do |station_details|
          raw_station_data = find_station(station_details['id'])
          extract_station_data(raw_station_data['data'], station_details)
        end
      else
        []
      end
    end

    def extract_station_data(data, station_details)
      {
        id: data['id'],
        name: data['name']['en'],
        latitude: data['location']['latitude'],
        longitude: data['location']['longitude'],
        elevation: data['location']['elevation'],
        distance: station_details['distance']
      }
    end

    def find_station(identifier)
      @cached_stations ||= {}
      @cached_stations[identifier] ||= download_station(identifier)
    end

    def download_station(identifier)
      meteostat_api.find_station(identifier)
    end

    def parse_temperature_reading(reading)
      # NOTE: we're parsing in the system time here, but Meteostat returns UTC
      [
        Time.zone.parse(reading['time']),
        reading['temp'].to_f
      ]
    end

    def meteostat_api
      @meteostat_api ||= MeteoStatApi.new(@api_key)
    end
  end
end
