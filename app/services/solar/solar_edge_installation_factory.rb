# frozen_string_literal: true

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
      information = if installation.consented?
                      api = installation.site_api!
                      site_details = api.details
                      dates = if site_details['activationStatus'] == 'ACTIVE'
                                api.date_range
                              else
                                {}
                              end
                      {
                        site_details:,
                        dates:
                      }
                    else
                      {
                        site_details: solar_edge_v1.site_details,
                        dates: solar_edge_v1.site_start_end_dates(installation.site_id)
                      }
                    end
      installation.update(information:)
    rescue StandardError => e
      Rollbar.error(e, job: :solar_download, school: installation.school)
    end

    def self.check(installation)
      if installation.consented?
        installation.refresh_tokens_if_needed!
      else
        solar_edge_v1.site_details
      end
      true
    rescue StandardError
      false
    end

    def self.setup_meters(installation)
      return if installation.setup_complete?
      return unless installation.can_complete_setup?

      first_reading_date = installation.site_api!.date_range[:from]&.to_date

      return unless first_reading_date

      Solar::SolarEdgeLoaderJob.perform_later(installation:,
                                              notify_email: installation.notify_email,
                                              start_date: first_reading_date,
                                              end_date: first_reading_date)
    end

    private

    def solar_edge_v1
      @solar_edge_v1 ||= DataFeeds::SolarEdgeApi.new(@installation.api_key)
    end
  end
end
