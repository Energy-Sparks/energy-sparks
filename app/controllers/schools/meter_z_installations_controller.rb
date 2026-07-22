# frozen_string_literal: true

module Schools
  class MeterZInstallationsController < BaseInstallationsController
    # skip_load_and_authorize_resource through: :school, instance_name: :installation
    skip_load_and_authorize_resource

    load_and_authorize_resource :meter_z_installation, instance_name: :installation

    MODEL = MeterZInstallation
    NAME = MODEL.model_name.human
    ID_PREFIX = 'meter-z'
    JOB_CLASS = Solar::SolisCloudLoaderJob

    private

    def find_existing_by_api_details = MeterZInstallation.find_by(api_key: @installation.api_key)

    def verify_and_update_installation
      api = @installation.api
      organisation_id = api.organisations.first['organisation_id']
      @installation.update!(meters_list: api.meters(organisation_id))
    end

    def installation_ok?
      update_installation_with_meters
      @installation.meters_list.present?
    end

    def resource_params
      params.expect(meter_z_installation: %i[api_key active])
    end
  end
end
