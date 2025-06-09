# frozen_string_literal: true

module Schools
  class SolisCloudInstallationsController < BaseInstallationsController
    NAME = 'SolisCloud'
    ID_PREFIX = 'solis-cloud'
    JOB_CLASS = Solar::SolisCloudLoaderJob

    def create
      @installation = if params[:existing].present?
                        SolisCloudInstallation.find(params[:existing])
                      else
                        SolisCloudInstallation.new(
                          api_id: resource_params[:api_id],
                          api_secret: resource_params[:api_secret],
                          amr_data_feed_config: AmrDataFeedConfig.find_by!(identifier: 'solis-cloud')
                        )
                      end
      if params[:existing].present? || @installation.save
        @school.solis_cloud_installations << @installation
        begin
          @installation.update_inverter_detail_list
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
      if @installation.update(resource_params)
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

    def resource_params
      params.require(:solis_cloud_installation).permit(:api_id, :api_secret)
    end
  end
end
