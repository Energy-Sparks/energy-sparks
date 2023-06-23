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
    rescue => e
      import_log.update!(error_messages: "Error downloading data from #{@start_date} to #{@end_date} for school id #{@low_carbon_hub_installation.school_id} : #{e.class}  #{e.message}")
      return nil
    end
  end
end
