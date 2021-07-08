module Solar
  class SolarEdgeDownloadAndUpsert
    def initialize(
        solar_edge_installation:,
        start_date:,
        end_date:
      )
      @solar_edge_installation = solar_edge_installation
      @solar_edge_api = SolarEdgeSolarPV.new(@solar_edge_installation.api_key)
      @start_date = start_date
      @end_date = end_date
    end

    def perform
      readings = SolarEdgeDownloader.new(solar_edge_installation: @solar_edge_installation, start_date: @start_date, end_date: @end_date, solar_edge_api: @solar_edge_api).readings
      SolarEdgeUpserter.new(solar_edge_installation: @solar_edge_installation, readings: readings).perform
    end
  end
end
