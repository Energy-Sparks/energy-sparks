module Solar
  class SolarEdgeDownloadAndUpsert < BaseDownloadAndUpsert
    def initialize(
        installation:,
        start_date:,
        end_date:
      )
      super(start_date: start_date, end_date: end_date, installation: installation)
    end

    def download_and_upsert
      readings = SolarEdgeDownloader.new(installation: @installation, start_date: start_date, end_date: end_date, api: solar_edge_api).readings
      SolarEdgeUpserter.new(solar_edge_installation: @installation, readings: readings, import_log: import_log).perform
    end

    def job
      :solar_edge_download
    end

    private

    def solar_edge_api
      SolarEdgeSolarPV.new(@installation.api_key)
    end
  end
end
