require 'dashboard'

module Solar
  class SolarEdgeInstallationFactory
    def initialize(
      school:,
      mpan:,
      site_id:,
      api_key:,
      amr_data_feed_config:
    )
      @school = school
      @mpan = mpan
      @site_id = site_id
      @api_key = api_key
      @amr_data_feed_config = amr_data_feed_config
      unless amr_data_feed_config.solar_edge_api?
        raise ArgumentError, 'Amr Data Feed Config is not set for the Solar Edge API'
      end
    end

    def self.update_information(installation)
      solar_edge_api = SolarEdgeAPI.new(installation.api_key)
      installation.update(information: {
                            site_details: solar_edge_api.site_details,
                            dates: solar_edge_api.site_start_end_dates(installation.site_id)
                          })
    rescue StandardError => e
      Rollbar.error(e, job: :solar_download, school: installation.school)
    end

    def perform
      installation = SolarEdgeInstallation.where(school_id: @school.id, mpan: @mpan, site_id: @site_id, api_key: @api_key, amr_data_feed_config: @amr_data_feed_config).first_or_create!

      installation.update(information: information)

      # Retrieve two days worth of data, just to get the meters set up and ensure some data comes back
      SolarEdgeDownloadAndUpsert.new(
        installation: installation,
        start_date: first_reading_date,
        end_date: first_reading_date + 1.day
      ).perform

      installation
    end

    private

    def solar_edge_api
      @solar_edge_api ||= SolarEdgeAPI.new(@api_key)
    end

    def first_reading_date
      @first_reading_date ||= solar_edge_api.site_start_end_dates(@site_id).first
    end

    def information
      {
        site_details: solar_edge_api.site_details,
        dates: solar_edge_api.site_start_end_dates(@site_id)
      }
    end
  end
end
