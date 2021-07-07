module Schools
  class RtoneVariantInstallationsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    before_action :load_non_gas_meters

    def new
      @rtone_variant_installation = RtoneVariantInstallation.new
      @rtone_variant_installation.meter = @non_gas_meters.first
    end

    def create
      if @rtone_variant_installation.save
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'New Rtone Variant API feed created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @rtone_variant_installation.update(rtone_variant_installation_params)
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'New Rtone Variant API feed updated.'
      else
        render :edit
      end
    end

    def destroy
      @rtone_variant_installation.destroy
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'New Rtone Variant API feed deleted.'
    end

    private

    def load_non_gas_meters
      @non_gas_meters = @school.meters.where.not(meter_type: :gas)
    end

    def rtone_variant_installation_params
      params.require(:rtone_variant_installation).permit(
        :amr_data_feed_config_id, :meter_id, :rtone_meter_id, :rtone_component_type, :username, :password
      )
    end
  end
end
