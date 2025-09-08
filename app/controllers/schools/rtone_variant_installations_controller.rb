# frozen_string_literal: true

module Schools
  class RtoneVariantInstallationsController < BaseInstallationsController
    before_action :load_non_gas_meters

    ID_PREFIX = 'rtone-variant'
    NAME = 'Rtone Variant API feed'
    JOB_CLASS = Solar::RtoneVariantLoaderJob

    def new
      @installation = RtoneVariantInstallation.new
      @installation.meter = @non_gas_meters.first
    end

    def create
      if @installation.save
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'New Rtone Variant API feed created.'
      else
        render :new
      end
    end

    def destroy
      @installation.destroy
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'New Rtone Variant API feed deleted.'
    end

    def check
      @api_ok = Solar::LowCarbonHubInstallationFactory.check(@installation)
      respond_to(&:js)
    end

    private

    def load_non_gas_meters
      @non_gas_meters = @school.meters.where.not(meter_type: :gas)
    end

    def resource_params
      params.require(:rtone_variant_installation).permit(
        :amr_data_feed_config_id, :meter_id, :rtone_meter_id, :rtone_component_type, :username, :password
      )
    end
  end
end
