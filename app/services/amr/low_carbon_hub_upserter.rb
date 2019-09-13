require 'dashboard'

module Amr
  class LowCarbonHubUpserter
    def initialize(low_carbon_hub_installation, low_carbon_hub_api = LowCarbonHubMeterReadings.new)
      @low_carbon_hub_installation = low_carbon_hub_installation
      @low_carbon_hub_api = low_carbon_hub_api
    end

    def perform
      pp current_information
      pp readings
    end

    private

    def meter_setup

    end

    def current_information
      @low_carbon_hub_api.full_installation_information(low_carbon_hub_installation.rbee_meter_id)
    end

    def first_reading_date
      @low_carbon_hub_api.first_meter_reading_date(low_carbon_hub_installation.rbee_meter_id)
    end

    def readings(start_date = Date.yesterday, end_date = Date.yesterday - 5.days)
      @low_carbon_hub_api.download(
        low_carbon_hub_installation.rbee_meter_id,
        low_carbon_hub_installation.school_number,
        start_date,
        end_date
      )
    end
  end
end
