# frozen_string_literal: true

# Interface to Meteostat weather data
#
# documentation: https://dev.meteostat.net/api/point/hourly.html
#
require 'json'
require 'faraday'
require 'faraday/retry'
require 'limiter'

module DataFeeds
  class MeteoStatApi
    extend Limiter::Mixin

    BASE_URL = 'https://meteostat.p.rapidapi.com'

    # limit rate of 'get' method calls to 4 requests per second, although we can do up to 10
    # https://github.com/Shopify/limiter
    limit_method :get, rate: 4, interval: 1

    def initialize(api_key, stubs = nil)
      @api_key = api_key
      # retries 2 times, and honours the Retry-After time requested by server
      # https://github.com/lostisland/faraday/blob/master/docs/middleware/request/retry.md
      @connection = FaradayHelper.connection(url: BASE_URL, headers:, retry_options: { retry_statuses: [429] }) do |f|
        f.adapter(:test, stubs) if stubs
        f.response :json
      end
    end

    def historic_temperatures(latitude, longitude, start_date, end_date, altitude)
      get(historic_temperatures_url(latitude, longitude, start_date, end_date, altitude))
    end

    def nearby_stations(latitude, longitude, number_of_results, within_radius_km)
      get(nearby_stations_url(latitude, longitude, number_of_results, within_radius_km))
    end

    def find_station(identifier) = get(find_station_url(identifier))

    private

    def historic_temperatures_url(latitude, longitude, start_date, end_date, altitude)
      '/point/hourly' \
      '?lat=' + latitude.to_s +
        '&lon='     + longitude.to_s +
        '&alt='     + altitude.to_i.to_s +
        '&start='   + url_date(start_date) +
        '&end='     + url_date(end_date) +
        '&tz=Europe/London'
    end

    def nearby_stations_url(latitude, longitude, number_of_results, within_radius_km)
      '/stations/nearby' \
      '?lat=' + latitude.to_s +
        '&lon='     + longitude.to_s +
        '&limit='   + number_of_results.to_i.to_s +
        '&radius='  + within_radius_km.to_i.to_s
    end

    def find_station_url(identifier) = "/stations/meta?id=#{identifier}"

    def url_date(date) = date.strftime('%Y-%m-%d')

    def headers
      {
        'x-rapidapi-host' => 'meteostat.p.rapidapi.com',
        'x-rapidapi-key' => @api_key
      }
    end

    def get(url) = @connection.get(url).body
  end
end
