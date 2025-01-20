# frozen_string_literal: true

module Schools
  class SolisCloudInstallationsController < BaseInstallationsController
    NAME = 'SolisCloud'
    ID_PREFIX = 'solis-cloud'
    JOB_CLASS = Solar::SolisCloudLoaderJob

    def show; end

    def new; end

    def edit; end

    def create
      @installation = SolisCloudInstallation.new(
        school: @school,
        api_id: solis_cloud_installation_params[:api_id],
        api_secret: solis_cloud_installation_params[:api_secret],
        amr_data_feed_config: AmrDataFeedConfig.find_by!(identifier: 'solis-cloud')
      )
      if @installation.save
        begin
          @installation.update_station_list
        rescue StandardError
          notice = 'SolisCloud installation was created but did not verify'
        else
          notice = 'SolisCloud installation was successfully created.'
        end
        redirect_to school_solar_feeds_configuration_index_path(@school), notice:

      else
        render :new
      end
    rescue StandardError => e
      Rollbar.error(e, job: :solar_download, school: @school)
      flash[:error] = e.message
      render :new
    end

    def update
      if @installation.update(solis_cloud_installation_params)
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'SolisCloud API feed was updated'
      else
        render :edit
      end
    end

    def check
      begin
        @api_ok = @installation.update_station_list.present?
      rescue StandardError
        @api_ok = false
      end
      respond_to(&:js)
    end

    private

    def solis_cloud_installation_params
      params.require(:solis_cloud_installation).permit(:api_id, :api_secret)
    end
  end
end
