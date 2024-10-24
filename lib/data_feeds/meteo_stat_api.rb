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

    # limit rate of 'get' method calls to 4 requests per second, although we can do up to 10
    # https://github.com/Shopify/limiter
    limit_method :get, rate: 4, interval: 1

    class RateLimitError < StandardError; end
    class HttpError < StandardError; end

    def initialize(api_key, stubs = nil)
      @api_key = api_key
      # retries 2 times, and honours the Retry-After time requested by server
      # https://github.com/lostisland/faraday/blob/master/docs/middleware/request/retry.md
      @connection = Faraday.new(url: base_url, headers:) do |f|
        f.adapter(:test, stubs) if stubs
        f.request(:retry, retry_options)
      end
    end

    def historic_temperatures(latitude, longitude, start_date, end_date, altitude)
      get(historic_temperatures_url(latitude, longitude, start_date, end_date, altitude))
    end

    def nearby_stations(latitude, longitude, number_of_results, within_radius_km)
      get(nearby_stations_url(latitude, longitude, number_of_results, within_radius_km))
    end

    def find_station(identifier)
      get(find_station_url(identifier))
    end

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

    def find_station_url(identifier)
      '/stations/meta' \
        "?id=#{identifier}"
    end

    def url_date(date)
      date.strftime('%Y-%m-%d')
    end

    def headers
      {
        'x-rapidapi-host' => 'meteostat.p.rapidapi.com',
        'x-rapidapi-key' => @api_key
      }
    end

    def base_url
      'https://meteostat.p.rapidapi.com'
    end

    # TODO: not clear if used in rapidapi version, but keep in place for now
    def retry_options
      {
        retry_statuses: [429],
        max: 2,
        interval: 0.5,
        interval_randomness: 0.5,
        backoff_factor: 2
        # retry_block: -> (x) { binding.pry }
      }
    end

    def get(url)
      response = @connection.get(url)
      raise HttpError, "status #{response.status} #{response.body}" unless response.status == 200

      JSON.parse(response.body)
    end
  end
end
