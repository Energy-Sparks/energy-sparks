# frozen_string_literal: true

require 'dashboard'

module Solar
  class SolarEdgeService
    def initialize(installation)
      @installation = installation
    end

    def update_information
      @installation.update!(information: fetch_information)
    rescue StandardError => e
      Rollbar.error(e, job: :solar_download, school: @installation.school.slug)
    end

    def check
      return false unless @installation.consented?

      @installation.refresh_api_tokens!
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
      return unless @installation.consented?

      information = {
        dates: @installation.information&.dig('dates')
      }

      api = @installation.site_api!
      site_details = api.details

      information[:site_details] = site_details
      information[:inventory] = api.inventory

      if refresh_dates?(previous_information: @installation.information, current_site_details: site_details)
        information[:dates] = api.date_range.transform_values(&:iso8601)
      end

      information
    end

    def refresh_dates?(previous_information:, current_site_details:)
      # Migrating from v1 to v2
      return true if previous_information&.dig('dates').is_a?(Array)

      previous_status = previous_information&.dig('site_details', 'activationStatus')
      current_status = current_site_details['activationStatus']

      previous_status != 'ACTIVE' && current_status == 'ACTIVE'
    end
  end
end
