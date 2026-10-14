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
      return unless monitoring_active?

      readings = SolarEdgeDownloader.new(installation: @installation, start_date: start_date, end_date: end_date, api: solar_edge_api).readings
      SolarEdgeUpserter.new(installation: @installation, readings: readings, import_log: import_log).perform
    end

    def job
      :solar_edge_download
    end

    protected

    def start_date
      return nil if @reload

      if @requested_start_date
        @requested_start_date
      elsif latest_reading.nil?
        nil
      else
        [latest_reading, Date.yesterday].min
      end
    end

    def end_date
      return nil if @reload

      super
    end

    private

    def monitoring_active?
      return true if @installation.monitoring_active?

      # refresh local copy of site status and recheck
      SolarEdgeInstallationFactory.update_information(@installation)

      @installation.monitoring_active?
    end

    def solar_edge_api
      DataFeeds::SolarEdgeApi.new(@installation.api_key)
    end
  end
end
