require 'dashboard'

module Amr
  class LowCarbonHubInstallationFactory
    def initialize(school:, rbee_meter_id:, low_carbon_hub_api: LowCarbonHubMeterReadings.new, amr_data_feed_config:)
      @low_carbon_hub_api = low_carbon_hub_api
      @school = school
      @rbee_meter_id = rbee_meter_id
      @amr_data_feed_config = amr_data_feed_config
    end

    def perform
      installation = LowCarbonHubInstallation.where(school_id: @school.id, rbee_meter_id: @rbee_meter_id,).first_or_create!
      installation.update(information: information.to_json)

      readings = LowCarbonHubDownloader.new(low_carbon_hub_installation: installation, start_date: first_reading_date, end_date: first_reading_date + 1.day, low_carbon_hub_api: @low_carbon_hub_api).readings

      LowCarbonHubUpserter.new(low_carbon_hub_installation: installation, readings: readings, amr_data_feed_config: @amr_data_feed_config).perform
      installation
    end

    private

    def information
      @low_carbon_hub_api.full_installation_information(@rbee_meter_id)
    end

    def first_reading_date
      @first_reading_date ||= @low_carbon_hub_api.first_meter_reading_date(@rbee_meter_id)
    end
  end
end
