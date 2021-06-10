require 'dashboard'

module Amr
  class LowCarbonHubDownloader
    def initialize(
        low_carbon_hub_installation:,
        start_date:,
        end_date:,
        low_carbon_hub_api:
      )
      @low_carbon_hub_installation = low_carbon_hub_installation
      @low_carbon_hub_api = low_carbon_hub_api
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
