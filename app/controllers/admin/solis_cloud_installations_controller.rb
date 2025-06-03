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
        Meter.find(params[:button].split('_').last)&.destroy
      elsif params[:button]&.start_with?('create_meter_')
        serial = params[:button].split('_').last
        Meter.create!(meter_serial_number: serial, school_id: params[:inverters][serial],
                      solis_cloud_installation: @resource,
                      meter_type: :solar_pv, pseudo: true, active: false,
                      mpan_mprn: Solar::SolisCloudUpserter.mpan(serial),
                      name: meter_name(serial))
      end
    end

    def meter_name(serial)
      inverter = @resource.inverter_detail_list.find { |inverter| inverter['sn'] == serial }
      "SolisCloud #{inverter&.[]('name') || inverter&.[]('stationName') || serial}"
    end
  end
end
