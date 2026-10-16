# frozen_string_literal: true

require 'dashboard'

module Solar
  class SolarEdgeService
    def initialize(installation)
      @installation = installation
    end

    def update_information
      @installation.update(information: fetch_information)
    rescue StandardError => e
      Rollbar.error(e, job: :solar_download, school: @installation.school)
    end

    def check
      if @installation.consented?
        @installation.refresh_api_tokens!
      else
        solar_edge_v1.site_details
      end
      true
    rescue StandardError
      false
    end

    def setup_meters
      return if @installation.setup_complete?
      return unless @installation.can_complete_setup?

      first_reading_date = @installation.site_api!.date_range[:from]&.to_date

      return unless first_reading_date

      Solar::SolarEdgeLoaderJob.perform_later(installation: @installation,
                                              notify_email: @installation.notify_email,
                                              start_date: first_reading_date,
                                              end_date: first_reading_date)
    end

    private

    def fetch_information
      if @installation.consented?
        api = @installation.site_api!
        site_details = api.details
        dates = if site_details['activationStatus'] == 'ACTIVE'
                  api.date_range
                else
                  {}
                end
        {
          site_details:,
          inventory: api.inventory,
          dates:
        }
      else
        {
          site_details: solar_edge_v1.site_details,
          dates: solar_edge_v1.site_start_end_dates(@installation.site_id)
        }
      end
    end

    def solar_edge_v1
      @solar_edge_v1 ||= DataFeeds::SolarEdgeApi.new(@installation.api_key)
    end
  end
end
