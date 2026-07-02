require 'dashboard'

module Solar
  class LowCarbonHubInstallationFactory
    def initialize(installation, amr_data_feed_config)
      @installation = installation
      @amr_data_feed_config = amr_data_feed_config
      return if amr_data_feed_config.low_carbon_hub_api?

      raise ArgumentError, 'Amr Data Feed Config is not set for the Low carbon hub API'
    end

    def perform
      installation = LowCarbonHubInstallation.where(school_id: @installation.school.id,
                                                    rbee_meter_id: @installation.rbee_meter_id,
                                                    amr_data_feed_config: @amr_data_feed_config).first_or_create!
      # save credentials to avoid api error meaning they're not saved
      installation.update(username:, password:, active: @installation.active)
      installation.update(information:)
      download_initial_readings(installation)
      installation
    end

    def self.check(installation)
      username = installation.username || ENV.fetch('ENERGYSPARKSRBEEUSERNAME', nil)
      password = installation.password || ENV.fetch('ENERGYSPARKSRBEEPASSWORD', nil)
      begin
        meter_id = if installation.is_a?(LowCarbonHubInstallation)
                     installation.rbee_meter_id
                   else
                     installation.rtone_meter_id
                   end
        DataFeeds::LowCarbonHubMeterReadings.new(username, password).full_installation_information(meter_id)
        true
      rescue StandardError => e
        puts e.message
        puts e.backtrace
        false
      end
    end

    private

    def low_carbon_hub_api
      @low_carbon_hub_api ||= DataFeeds::LowCarbonHubMeterReadings.new(username, password)
    end

    def information
      low_carbon_hub_api.full_installation_information(@installation.rbee_meter_id)
    end

    def first_reading_date
      @first_reading_date ||= low_carbon_hub_api.first_meter_reading_date(@installation.rbee_meter_id)
    end

    def username
      @installation.username || ENV.fetch('ENERGYSPARKSRBEEUSERNAME', nil)
    end

    def password
      @installation.password || ENV.fetch('ENERGYSPARKSRBEEPASSWORD', nil)
    end

    def download_initial_readings(installation)
      # Retrieve two days worth of data, just to get the meters set up and ensure some data comes back
      LowCarbonHubDownloadAndUpsert.new(installation:,
                                        start_date: first_reading_date,
                                        end_date: first_reading_date + 1.day).perform
    end
  end
end
