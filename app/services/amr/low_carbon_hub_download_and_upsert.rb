module Amr
  class LowCarbonHubDownloadAndUpsert
    def initialize(low_carbon_hub_installation:, start_date: Date.yesterday, end_date: Date.yesterday - 5.days, low_carbon_hub_api: LowCarbonHubMeterReadings.new, amr_data_feed_config:)
      @low_carbon_hub_installation = low_carbon_hub_installation
      @low_carbon_hub_api = low_carbon_hub_api
      @start_date = start_date
      @end_date = end_date
      @amr_data_feed_config = amr_data_feed_config
    end

    def perform
      readings = LowCarbonHubDownloader.new(low_carbon_hub_installation: @low_carbon_hub_installation, start_date: @start_date, end_date: @end_date, low_carbon_hub_api: @low_carbon_hub_api).readings
      LowCarbonHubUpserter.new(low_carbon_hub_installation: @low_carbon_hub_installation, readings: readings, amr_data_feed_config: @amr_data_feed_config).perform
    end
  end
end
