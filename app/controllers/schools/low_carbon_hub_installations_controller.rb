# frozen_string_literal: true

module Schools
  class LowCarbonHubInstallationsController < BaseInstallationsController
    ID_PREFIX = 'low-carbon-hub'
    NAME = 'Rtone API feed'
    JOB_CLASS = Solar::LowCarbonHubLoaderJob

    def create
      @installation = Solar::LowCarbonHubInstallationFactory.new(
        school: @school,
        rbee_meter_id: resource_params[:rbee_meter_id],
        username: resource_params[:username],
        password: resource_params[:password],
        amr_data_feed_config: AmrDataFeedConfig.find(resource_params[:amr_data_feed_config_id])
      ).perform

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
      params.require(:low_carbon_hub_installation).permit(
        :rbee_meter_id, :amr_data_feed_config_id, :username, :password
      )
    end

    def formatted_localised_utc_time(time_string)
      Time.find_zone('UTC').parse(time_string).localtime.strftime('%H:%M')
    end
  end
end
