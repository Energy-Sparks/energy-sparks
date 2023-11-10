module Schools
  class SolarEdgeInstallationsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    def new
    end

    def create
      @solar_edge_installation = Solar::SolarEdgeInstallationFactory.new(
        school: @school,
        mpan: solar_edge_installation_params[:mpan],
        site_id: solar_edge_installation_params[:site_id],
        api_key: solar_edge_installation_params[:api_key],
        amr_data_feed_config: AmrDataFeedConfig.find(solar_edge_installation_params[:amr_data_feed_config_id]),
      ).perform

      if @solar_edge_installation.persisted?
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'Solar Edge installation was successfully created.'
      else
        render :new
      end
    rescue => e
      Rollbar.error(e, job: :solar_download, school: @school)
      flash[:error] = e.message
      render :new
    end

    def edit
    end

    def update
      if @solar_edge_installation.update(solar_edge_installation_params)
        Solar::SolarEdgeInstallationFactory.update_information(@solar_edge_installation)
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'Solar Edge API feed was updated'
      else
        render :edit
      end
    end

    def destroy
      @solar_edge_installation.meters.each do |meter|
        MeterManagement.new(meter).delete_meter!
      end

      @solar_edge_installation.destroy
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: "Solar Edge API feed deleted"
    end

    def check
      @api_ok = Solar::SolarEdgeInstallationFactory.check(@solar_edge_installation)
      respond_to(&:js)
    end

    def submit_job
      Solar::SolarEdgeLoaderJob.perform_later(installation: @solar_edge_installation, notify_email: current_user.email)
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: "Loading job has been submitted. An email will be sent to #{current_user.email} when complete."
    end

    private

    def solar_edge_installation_params
      params.require(:solar_edge_installation).permit(
        :site_id, :amr_data_feed_config_id, :mpan, :api_key
      )
    end
  end
end
