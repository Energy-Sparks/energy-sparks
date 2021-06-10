module Schools
  class SolarEdgeInstallationsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    def new
    end

    def create
      if @solar_edge_installation.save
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'New Solar Edge installation created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @solar_edge_installation.update(solar_edge_installation_params)
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: 'Installation was updated'
      else
        render :edit
      end
    end

    def destroy
      @solar_edge_installation.meters.each do |meter|
        MeterManagement.new(meter).delete_meter!
      end

      @solar_edge_installation.destroy
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: "Solar Edge Installation deleted"
    end

    private

    def solar_edge_installation_params
      params.require(:solar_edge_installation).permit(
        :site_id, :amr_data_feed_config_id, :mpan, :api_key
      )
    end
  end
end
