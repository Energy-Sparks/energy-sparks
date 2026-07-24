# frozen_string_literal: true

module Schools
  class SolisCloudInstallationsController < BaseInstallationsController
    MODEL = SolisCloudInstallation
    NAME = MODEL.model_name.human
    ID_PREFIX = 'solis-cloud'
    JOB_CLASS = Solar::SolisCloudLoaderJob

    def destroy
      @installation.schools.destroy(@school)
      @installation.schools.reload
      super
    end

    private

    def find_existing_by_api_details = SolisCloudInstallation.find_by(api_id: @installation.api_id)

    def verify_and_update_installation
      @school.solis_cloud_installations << @installation
      @installation.update_inverter_detail_list
    end

    def installation_ok? = @installation.update_inverter_detail_list.present?

    def resource_params = params.expect(solis_cloud_installation: %i[api_id api_secret active])
  end
end
