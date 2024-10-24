module Solar
  class RtoneVariantDownloadAndUpsert < BaseDownloadAndUpsert
    def initialize(
        installation:,
        start_date:,
        end_date:
      )
      super(start_date: start_date, end_date: end_date, installation: installation)
    end

    def download_and_upsert
      readings = RtoneVariantDownloader.new(installation: @installation, start_date: start_date, end_date: end_date, api: low_carbon_hub_api).readings

      RtoneVariantUpserter.new(installation: @installation, readings: readings, import_log: import_log).perform
    end

    def job
      :rtone_variant_download
    end

    private

    def low_carbon_hub_api
      @low_carbon_hub_api ||= DataFeeds::LowCarbonHubMeterReadings.new(username, password)
    end

    def username
      @installation.username
    end

    def password
      @installation.password
    end
  end
end
