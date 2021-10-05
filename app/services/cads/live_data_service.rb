module Cads
  class LiveDataService
    def initialize(cad)
      @cad = cad
    end

    def read
      result = { type: :electricity, units: :watts, value: 0, timestamp: 0 }
      data = api.live_data(@cad.device_identifier)
      if data['powerTimestamp'] == 0
        ret = api.trigger_fast_update(@cad.device_identifier)
        puts "ret from trigger: #{ret}"
      else
        result[:timestamp] = data['powerTimestamp']
        if data['power']
          data['power'].each do |power_entry|
            if power_entry['type'] == 'ELECTRICITY'
              result[:value] = power_entry['watts']
            end
          end
        end
      end
      result
    end

    private

    def api
      unless @api
        @api = MeterReadingsFeeds::GeoApi.new(username: ENV['GEO_API_USERNAME'], password: ENV['GEO_API_PASSWORD'])
        @api.login
      end
      @api
    end
  end
end
