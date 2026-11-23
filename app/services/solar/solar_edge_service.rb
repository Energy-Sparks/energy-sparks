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

      Solar::SolarEdgeLoaderJob.perform_later(installation: @installation,
                                              notify_email: @installation.notify_email)
    end

    private

    def fetch_information
      return unless @installation.consented?

      api = @installation.site_api!

      {
        site_details: api.details,
        inventory: api.inventory
      }
    end
  end
end
