# frozen_string_literal: true

module Schools
  class MeterZInstallationsController < BaseInstallationsController
    # load_and_authorize_resource through: :school, instance_name: :installation
    # skip_load_and_authorize_resource :installation
    load_and_authorize_resource :meter_z_installation, instance_name: :installation

    MODEL = MeterZInstallation
    NAME = MODEL.model_name.human
    ID_PREFIX = 'meter-z'
    JOB_CLASS = Solar::SolisCloudLoaderJob

    def create
      existing_or_create
      if params[:existing].present? || @installation.save
        # @school.meter_z_installations << @installation
        begin
          update_installation_with_meters
        rescue StandardError
          notice = "#{self.class::MODEL.model_name.human} was created but did not verify. " \
                   'Check API details and try updating the inverter list again'
        else
          notice = "#{self.class::MODEL.model_name.human} was successfully created."
        end
        redirect_to edit_school_meter_z_installation_path(@school, @installation), notice:
      else
        render :new
      end
    rescue StandardError => e
      Rollbar.error(e, job: :solar_download, school: @school)
      flash[:error] = e.message
      render :new
    end

    def update
      if params[:unassign].present?
        meter = Meter.find(params.expect(:unassign))
        MeterManagement.new(meter).delete_meter! if meter
        redirect_to edit_school_solis_cloud_installation_path(@school, @installation), notice: 'Meter unassigned' # rubocop:disable Rails/I18nLocaleTexts
      elsif params[:assign].present?
        @installation.create_meter(params[:assign], @school.id)
        redirect_to edit_school_meter_z_installation_path(@school, @installation), notice: 'Meter assigned' # rubocop:disable Rails/I18nLocaleTexts
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

    private

    def update_installation_with_meters
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
