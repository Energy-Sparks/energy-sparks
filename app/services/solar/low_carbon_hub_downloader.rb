require 'dashboard'

module Solar
  class LowCarbonHubDownloader
    def initialize(
        installation:,
        start_date:,
        end_date:,
        api:
      )
      @low_carbon_hub_installation = installation
      @low_carbon_hub_api = api
      @start_date = start_date
      @end_date = end_date
    end

    def readings
      @low_carbon_hub_api.download(
        @low_carbon_hub_installation.rbee_meter_id,
        @low_carbon_hub_installation.school_number,
        @start_date,
        @end_date
      )
    end
  end
end
