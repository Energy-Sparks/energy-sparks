module Solar
  class SolarEdgeDownloadAndUpsert < BaseDownloadAndUpsert
    def initialize(
        installation:,
        start_date:,
        end_date:,
        reload: false
      )
      super(start_date: start_date, end_date: end_date, installation: installation)
      @reload = reload
    end

    def download_and_upsert
      readings = SolarEdgeDownloader.new(installation: @installation, start_date: start_date, end_date: end_date, api: solar_edge_api).readings
      SolarEdgeUpserter.new(installation: @installation, readings: readings, import_log: import_log).perform
    end

    def job
      :solar_edge_download
    end

    protected

    def start_date
      return nil if @reload

      super
    end

    def end_date
      return nil if @reload

      super
    end

    private

    def solar_edge_api
      DataFeeds::SolarEdgeApi.new(@installation.api_key)
    end
  end
end
