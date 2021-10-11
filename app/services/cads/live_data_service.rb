module Cads
  class LiveDataService
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
      result / 1000.0
    end

    private

    def power_for_type(powers, type)
      if powers
        power = powers.select { |p| p['type'].downcase == type.to_s }.last
      end
      power ? power['watts'] : 0
    end

    def api
      unless @api
        @api = MeterReadingsFeeds::GeoApi.new(username: ENV['GEO_API_USERNAME'], password: ENV['GEO_API_PASSWORD'])
        @api.login
      end
      @api
    end
  end
end
