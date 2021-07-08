require 'dashboard'

module Solar
  class SolarEdgeDownloader
    def initialize(
        installation:,
        start_date:,
        end_date:,
        api:
      )
      @solar_edge_installation = installation
      @solar_edge_api = api
      @start_date = start_date
      @end_date = end_date
    end

    def readings
      @solar_edge_api.smart_meter_data(
        @solar_edge_installation.site_id,
        @start_date,
        @end_date
      )
    end
  end
end
