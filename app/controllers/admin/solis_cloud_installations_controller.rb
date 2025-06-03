# frozen_string_literal: true

module Admin
  class SolisCloudInstallationsController < AdminCrudController
    NAME = 'SolisCloud'
    ID_PREFIX = 'solis-cloud'
    MODEL = SolisCloudInstallation

    def check
      begin
        @api_ok = @resource.update_inverter_detail_list.present?
      rescue StandardError
        @api_ok = false
      end
      respond_to do |format|
        format.html { redirect_to edit_admin_solis_cloud_installation_path(@resource) }
        format.js
      end
    end

    def destroy
      @resource.meters.each { |meter| MeterManagement.new(meter).delete_meter! }
      @resource.destroy
      redirect_to admin_solis_cloud_installations_path, notice: "#{self.class::NAME} API feed deleted"
    end

    def submit_job
      Solar::SolisCloudLoaderJob.perform_later(installation: @resource, notify_email: current_user.email)
      redirect_to admin_solis_cloud_installations_path,
                  notice: 'Loading job has been submitted. ' \
                          "An email will be sent to #{current_user.email} when complete."
    end

    private

    def on_create_success
      @installation.update_inverter_detail_list
      nil # use the standard notice
    rescue StandardError
      'SolisCloud installation was created but did not verify'
    end

    def on_update_success
      if params[:button]&.start_with?('remove_meter_')
        meter = Meter.find(params[:button].split('_').last)
        MeterManagement.new(meter).delete_meter! if meter
      elsif params[:button]&.start_with?('create_meter_')
        serial = params[:button].split('_').last
        @resource.create_meter(serial, params[:inverters][serial])
      end
    end
  end
end
