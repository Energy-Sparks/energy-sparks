module Solar
  class LowCarbonHubDownloadAndUpsert
    def initialize(
        low_carbon_hub_installation:,
        start_date:,
        end_date:
      )
      @low_carbon_hub_installation = low_carbon_hub_installation
      @start_date = start_date
      @end_date = end_date
    end

    def perform
      readings = LowCarbonHubDownloader.new(low_carbon_hub_installation: @low_carbon_hub_installation, start_date: @start_date, end_date: @end_date, low_carbon_hub_api: low_carbon_hub_api).readings
      LowCarbonHubUpserter.new(low_carbon_hub_installation: @low_carbon_hub_installation, readings: readings).perform
    end

    private

    def low_carbon_hub_api
      @low_carbon_hub_api ||= LowCarbonHubMeterReadings.new(username, password)
    end

    def username
      @low_carbon_hub_installation.username || ENV['ENERGYSPARKSRBEEUSERNAME']
    end

    def password
      @low_carbon_hub_installation.password || ENV['ENERGYSPARKSRBEEPASSWORD']
    end
  end
end
