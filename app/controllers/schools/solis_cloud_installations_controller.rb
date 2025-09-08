# frozen_string_literal: true

module Schools
  class SolisCloudInstallationsController < BaseInstallationsController
    MODEL = SolisCloudInstallation
    NAME = MODEL.model_name.human
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
          notice = "#{self.class::MODEL.model_name.human} was created but did not verify"
        else
          notice = "#{self.class::MODEL.model_name.human} was successfully created.  Edit to assign inverters."
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
      if params[:button]&.start_with?('unassign_meter_')
        meter = Meter.find(params[:button].split('_').last)
        MeterManagement.new(meter).delete_meter! if meter
        redirect_to edit_school_solis_cloud_installation_path(@school, @installation), notice: 'Meter unassigned'
      elsif params[:button]&.start_with?('assign_meter_')
        serial = params[:button].split('_').last
        @meter = @installation.create_meter(serial, @school.id)
        redirect_to edit_school_solis_cloud_installation_path(@school, @installation), notice: 'Meter assigned'
      elsif @installation.update(resource_params)
        redirect_to school_solar_feeds_configuration_index_path(@school),
                    notice: "#{self.class::MODEL.model_name.human} was updated"
      else
        render :edit
      end
    end

    def destroy
      SolisCloudInstallationSchool.where(school: @school, solis_cloud_installation: @installation).destroy_all
      @installation.schools.reload
      super
    end

    def check
      begin
        @api_ok = @installation.update_inverter_detail_list.present?
      rescue StandardError
        @api_ok = false
      end
      respond_to do |format|
        format.html { redirect_to edit_school_solis_cloud_installation_path(@school, @installation) }
        format.js
      end
    end

    private

    def resource_params
      params.require(:solis_cloud_installation).permit(:api_id, :api_secret)
    end
  end
end
