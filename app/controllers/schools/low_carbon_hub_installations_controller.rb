# frozen_string_literal: true

module Schools
  class LowCarbonHubInstallationsController < BaseInstallationsController
    ID_PREFIX = 'low-carbon-hub'
    NAME = 'Rtone API feed'
    JOB_CLASS = Solar::LowCarbonHubLoaderJob

    def create
      @installation = Solar::LowCarbonHubInstallationFactory.new(@installation,
                                                                 AmrDataFeedConfig.low_carbon_hub_api.first).perform

      if @installation.persisted?
        redirect_to school_solar_feeds_configuration_index_path(@school),
                    notice: "#{self.class::NAME} installation was successfully created."
      else
        render :new
      end
    rescue EnergySparksUnexpectedStateException
      redirect_to school_solar_feeds_configuration_index_path(@school),
                  notice: 'Rtone API is not available at the moment'
    rescue StandardError => e
      Rollbar.error(e)
      flash[:error] = e.message
      render :new
    end

    def check
      @api_ok = Solar::LowCarbonHubInstallationFactory.check(@installation)
      respond_to(&:js)
    end

    private

    def resource_params
      params.expect(low_carbon_hub_installation: %i[rbee_meter_id username password active])
    end

    def formatted_localised_utc_time(time_string)
      Time.find_zone('UTC').parse(time_string).localtime.strftime('%H:%M')
    end
  end
end
