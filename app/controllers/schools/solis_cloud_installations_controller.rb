# frozen_string_literal: true

module Schools
  class SolisCloudInstallationsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school
    before_action :set_breadcrumbs

    def show
      # @api_params = { api_key: @solar_edge_installation.api_key, format: :json }

      # return unless @solar_edge_installation.cached_api_information?

      # start_time = @solar_edge_installation.api_latest_data_date.strftime('%Y-%m-%d 00:00:00')
      # end_time = @solar_edge_installation.api_latest_data_date.strftime('%Y-%m-%d 00:00:00')
      # @reading_params = @api_params.merge({ timeUnit: 'QUARTER_OF_AN_HOUR', startTime: start_time,
      #                                       endTime: end_time })
    end

    def new; end

    def edit; end

    def create
      @solis_cloud_installation = SolisCloudInstallation.new(
        school: @school,
        api_id: solis_cloud_installation_params[:api_id],
        api_secret: solis_cloud_installation_params[:api_secret],
        amr_data_feed_config: AmrDataFeedConfig.find_by!(identifier: 'solis_cloud')
      )
      if @solis_cloud_installation.save
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
      @solar_edge_installation.meters.each do |meter|
        MeterManagement.new(meter).delete_meter!
      end

      @solar_edge_installation.destroy
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'Solar Edge API feed deleted'
    end

    def check
      begin
        @api_ok = @solis_cloud_installation.update_station_list.present?
      rescue StandardError
        raise
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

    def set_breadcrumbs
      @breadcrumbs = [
        { name: 'Solar API Feeds' }
      ]
    end
  end
end
