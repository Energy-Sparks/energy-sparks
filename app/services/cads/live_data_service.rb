module Cads
  class LiveDataService
    CACHE_KEY = 'geo-token'.freeze
    DEFAULT_EXPIRY = 45

    def initialize(cad)
      @cad = cad
    end

    def read(type = :electricity)
      result = 0
      data = api.live_data(@cad.device_identifier)
      if data['powerTimestamp'] == 0
        api.trigger_fast_update(@cad.device_identifier)
      else
        result = power_for_type(data['power'], type)
      end
      result
    rescue DataFeeds::GeoApi::NotAuthorised, DataFeeds::GeoApi::NotAllowed => e
      reset_token
      Rollbar.error(e, school_id: @cad.school.id, school: @cad.school.name, device_identifier: @cad.device_identifier)
    rescue => e
      Rollbar.error(e, school_id: @cad.school.id, school: @cad.school.name, device_identifier: @cad.device_identifier)
    end

    private

    def power_for_type(powers, type)
      if powers
        power = powers.select { |p| p['type'].downcase == type.to_s }.last
      end
      power ? power['watts'] : 0
    end

    def api
      @api ||= DataFeeds::GeoApi.new(token: token)
    end

    def token
      Rails.cache.fetch(CACHE_KEY, expires_in: expiry) do
        DataFeeds::GeoApi.new(username: ENV['GEO_API_USERNAME'], password: ENV['GEO_API_PASSWORD']).login
      end
    end

    def reset_token
      Rails.cache.delete(CACHE_KEY)
    end

    def expiry
      ENV['GEO_API_TOKEN_EXPIRY_MINUTES'].blank? ? DEFAULT_EXPIRY.minutes : ENV['GEO_API_TOKEN_EXPIRY_MINUTES'].to_i.minutes
    end
  end
end
