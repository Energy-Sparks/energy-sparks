module Schools
  class LowCarbonHubInstallationsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    def index
      @start_time = formatted_localised_utc_time('12pm')
      @end_time = formatted_localised_utc_time('1pm')
    end

    def new
    end

    def create
      @low_carbon_hub_installation = Amr::LowCarbonHubInstallationFactory.new(
        school: @school,
        rbee_meter_id: low_carbon_hub_installation_params[:rbee_meter_id],
        amr_data_feed_config: AmrDataFeedConfig.find(low_carbon_hub_installation_params[:amr_data_feed_config_id]),
      ).perform

      if @low_carbon_hub_installation.persisted?
        redirect_to school_low_carbon_hub_installation_path(@school, @low_carbon_hub_installation), notice: 'Low Carbon Hub installation was successfully created.'
      else
        render :new
      end
    rescue EnergySparksUnexpectedStateException
      redirect_to school_low_carbon_hub_installations_path(@school), notice: 'Low carbon hub API is not available at the moment'
    end

    def destroy
      @low_carbon_hub_installation.meters.each do |meter|
        MeterManagement.new(meter).delete_meter!
      end

      @low_carbon_hub_installation.destroy
      redirect_to school_low_carbon_hub_installations_path(@school), notice: 'Low carbon hub deleted'
    end

  private

    def low_carbon_hub_installation_params
      params.require(:low_carbon_hub_installation).permit(
        :rbee_meter_id, :amr_data_feed_config_id
      )
    end

    def formatted_localised_utc_time(time_string)
      Time.find_zone('UTC').parse(time_string).localtime.strftime('%H:%M')
    end
  end
end
