require 'dashboard'

module Solar
  class SolarEdgeInstallationFactory
    def initialize(installation, amr_data_feed_config)
      @installation = installation
      @amr_data_feed_config = amr_data_feed_config
      return if amr_data_feed_config.solar_edge_api?

      raise ArgumentError, 'Amr Data Feed Config is not set for the Solar Edge API'
    end

    def self.update_information(installation)
      update_installation_information(installation, DataFeeds::SolarEdgeApi.new(installation.api_key))
    rescue StandardError => e
      Rollbar.error(e, job: :solar_download, school: installation.school)
    end

    def self.check(installation)
      solar_edge_api = DataFeeds::SolarEdgeApi.new(installation.api_key)
      solar_edge_api.site_details
      true
    rescue StandardError
      false
    end

    def self.update_installation_information(installation, solar_edge_api)
      installation.update(information: { site_details: solar_edge_api.site_details,
                                         dates: solar_edge_api.site_start_end_dates(installation.site_id) })
    end

    def perform
      installation = SolarEdgeInstallation
                     .where(school_id: @installation.school.id,
                            mpan: @installation.mpan,
                            site_id: @installation.site_id,
                            api_key: @installation.api_key,
                            amr_data_feed_config: @amr_data_feed_config).first_or_create! do |installation|
        installation.active = @installation.active
      end
      self.class.update_installation_information(installation, solar_edge_api)
      download_initial_readings(installation)
      installation
    end

    private

    def solar_edge_api
      @solar_edge_api ||= DataFeeds::SolarEdgeApi.new(@installation.api_key)
    end

    def first_reading_date
      @first_reading_date ||= solar_edge_api.site_start_end_dates(@installation.site_id).first
    end

    def download_initial_readings(installation)
      # Retrieve two days worth of data, just to get the meters set up and ensure some data comes back
      return unless first_reading_date

      SolarEdgeDownloadAndUpsert.new(installation:,
                                     start_date: first_reading_date,
                                     end_date: first_reading_date + 1.day).perform
    end
  end
end
