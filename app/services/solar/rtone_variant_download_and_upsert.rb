module Solar
  class RtoneVariantDownloadAndUpsert
    def initialize(
        rtone_variant_installation:,
        start_date:,
        end_date:
      )
      @rtone_variant_installation = rtone_variant_installation
      @start_date = start_date
      @end_date = end_date
    end

    def perform
      readings = RtoneVariantDownloader.new(rtone_variant_installation: @rtone_variant_installation, start_date: @start_date, end_date: @end_date, low_carbon_hub_api: low_carbon_hub_api).readings
      RtoneVariantUpserter.new(rtone_variant_installation: @rtone_variant_installation, readings: readings).perform
    end

    private

    def low_carbon_hub_api
      @low_carbon_hub_api ||= LowCarbonHubMeterReadings.new(username, password)
    end

    def username
      @rtone_variant_installation.username
    end

    def password
      @rtone_variant_installation.password
    end
  end
end
