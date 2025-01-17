# frozen_string_literal: true

module Schools
  class SolisCloudInstallationsController < BaseInstallationsController
    NAME = 'SolisCloud'
    ID_PREFIX = 'solis-cloud'

    def show; end

    def new; end

    def edit; end

    def create
      @installation = SolisCloudInstallation.new(
        school: @school,
        api_id: solis_cloud_installation_params[:api_id],
        api_secret: solis_cloud_installation_params[:api_secret],
        amr_data_feed_config: AmrDataFeedConfig.find_by!(identifier: 'solis_cloud')
      )
      if @solis_cloud_installation.save
        # this should probably be a job
        SolisCloudDownloadAndUpsert.new(5.days.ago, nil, @installation).download_and_upsert
        redirect_to school_solar_feeds_configuration_index_path(@school),
                    notice: 'SolisCloud installation was successfully created.'
      else
        render :new
      end
    rescue StandardError => e
      Rollbar.error(e, job: :solar_download, school: @school)
      flash[:error] = e.message
      render :new
    end

    def update
      if @solis_cloud_installation.update(solis_cloud_installation_params)
        # Solar::SolarEdgeInstallationFactory.update_information(@solar_edge_installation)
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'SolisCloud API feed was updated'
      else
        render :edit
      end
    end

    def destroy
      @solis_cloud_installation.meters.each do |meter|
        MeterManagement.new(meter).delete_meter!
      end

      @solis_cloud_installation.destroy
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'SolarCloud API feed deleted'
    end

    def check
      begin
        @api_ok = @installation.update_station_list.present?
      rescue StandardError
        @api_ok = false
      end
      respond_to(&:js)
    end

    def submit_job
      Solar::SolarEdgeLoaderJob.perform_later(installation: @solar_edge_installation, notify_email: current_user.email)
      redirect_to school_solar_feeds_configuration_index_path(@school),
                  notice: "Loading job has been submitted. An email will be sent to #{current_user.email} when complete."
    end

    private

    def solis_cloud_installation_params
      params.require(:solis_cloud_installation).permit(:api_id, :api_secret)
    end
  end
end
