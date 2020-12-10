require 'dashboard'

module Amr
  class SolarEdgeDownloader
    def initialize(
        solar_edge_installation:,
        start_date:,
        end_date:,
        solar_edge_api:
      )
      @solar_edge_installation = solar_edge_installation
      @solar_edge_api = solar_edge_api
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
