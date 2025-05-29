# frozen_string_literal: true

module Admin
  class SolisCloudInstallationsController < AdminCrudController
    NAME = 'SolisCloud'
    ID_PREFIX = 'solis-cloud'
    JOB_CLASS = Solar::SolisCloudLoaderJob
    MODEL = SolisCloudInstallation

    def create
      @installation = SolisCloudInstallation.new(
        api_id: resource_params[:api_id],
        api_secret: resource_params[:api_secret],
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

    # def update
    #   if @installation.update(resource_params)
    #     redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'SolisCloud API feed was updated'
    #   else
    #     render :edit
    #   end
    # end

    def check
      begin
        @api_ok = @resource.update_inverter_detail_list.present?
      rescue StandardError
        @api_ok = false
      end
      respond_to(&:js)
    end

    # def show; end

    # def new; end

    # def edit; end

    # def update
    #   if @installation.update(resource_params)
    #     redirect_to school_solar_feeds_configuration_index_path(@school),
    #                 notice: "#{self.class::NAME} API feed was updated"
    #   else
    #     render :edit
    #   end
    # end

    def destroy
      @installation.meters.each { |meter| MeterManagement.new(meter).delete_meter! }
      @installation.destroy
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: "#{self.class::NAME} API feed deleted"
    end

    def submit_job
      self.class::JOB_CLASS.perform_later(installation: @installation, notify_email: current_user.email)
      redirect_to school_solar_feeds_configuration_index_path(@school),
                  notice: 'Loading job has been submitted. ' \
                          "An email will be sent to #{current_user.email} when complete."
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: 'Solar API Feeds' }]
    end

    private

    def resource_params
      params.require(:solis_cloud_installation).permit(:api_id, :api_secret)
    end
  end
end
