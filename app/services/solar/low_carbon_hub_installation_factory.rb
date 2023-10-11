require 'dashboard'

module Solar
  class LowCarbonHubInstallationFactory
    def initialize(
      school:,
      rbee_meter_id:,
      amr_data_feed_config:,
      username:,
      password:
    )
      @school = school
      @rbee_meter_id = rbee_meter_id
      @amr_data_feed_config = amr_data_feed_config
      @username = username
      @password = password
      unless amr_data_feed_config.low_carbon_hub_api?
        raise ArgumentError, 'Amr Data Feed Config is not set for the Low carbon hub API'
      end
    end

    def perform
      installation = LowCarbonHubInstallation.where(school_id: @school.id, rbee_meter_id: @rbee_meter_id, amr_data_feed_config: @amr_data_feed_config).first_or_create!
      # save credentials to avoid api error meaning they're not saved
      installation.update(username: username, password: password)
      installation.update(information: information)

      # Retrieve two days worth of data, just to get the meters set up and ensure some data comes back
      LowCarbonHubDownloadAndUpsert.new(
        installation: installation,
        start_date: first_reading_date,
        end_date: first_reading_date + 1.day
      ).perform

      installation
    end

    private

    def low_carbon_hub_api
      @low_carbon_hub_api ||= LowCarbonHubMeterReadings.new(username, password)
    end

    def information
      low_carbon_hub_api.full_installation_information(@rbee_meter_id)
    end

    def first_reading_date
      @first_reading_date ||= low_carbon_hub_api.first_meter_reading_date(@rbee_meter_id)
    end

    def username
      @username || ENV['ENERGYSPARKSRBEEUSERNAME']
    end

    def password
      @password || ENV['ENERGYSPARKSRBEEPASSWORD']
    end
  end
end
