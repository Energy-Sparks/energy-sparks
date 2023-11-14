module Schools
  class LowCarbonHubInstallationsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    def new
    end

    def create
      @low_carbon_hub_installation = Solar::LowCarbonHubInstallationFactory.new(
        school: @school,
        rbee_meter_id: low_carbon_hub_installation_params[:rbee_meter_id],
        username: low_carbon_hub_installation_params[:username],
        password: low_carbon_hub_installation_params[:password],
        amr_data_feed_config: AmrDataFeedConfig.find(low_carbon_hub_installation_params[:amr_data_feed_config_id]),
      ).perform

      if @low_carbon_hub_installation.persisted?
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'Low Carbon Hub installation was successfully created.'
      else
        render :new
      end
    rescue EnergySparksUnexpectedStateException
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'Rtone API is not available at the moment'
    rescue => e
      Rollbar.error(e)
      flash[:error] = e.message
      render :new
    end

    def edit
    end

    def update
      if @low_carbon_hub_installation.update(low_carbon_hub_installation_params)
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'Installation was updated'
      else
        render :edit
      end
    end

    def destroy
      @low_carbon_hub_installation.meters.each do |meter|
        MeterManagement.new(meter).delete_meter!
      end

      @low_carbon_hub_installation.destroy
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'Low carbon hub deleted'
    end

    def check
      @api_ok = Solar::LowCarbonHubInstallationFactory.check(@low_carbon_hub_installation)
      respond_to(&:js)
    end

    def submit_job
      Solar::LowCarbonHubLoaderJob.perform_later(installation: @low_carbon_hub_installation, notify_email: current_user.email)
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: "Loading job has been submitted. An email will be sent to #{current_user.email} when complete."
    end

  private

    def low_carbon_hub_installation_params
      params.require(:low_carbon_hub_installation).permit(
        :rbee_meter_id, :amr_data_feed_config_id, :username, :password
      )
    end

    def formatted_localised_utc_time(time_string)
      Time.find_zone('UTC').parse(time_string).localtime.strftime('%H:%M')
    end
  end
end
