module Admin
  class TransportTypesController < AdminController
    load_and_authorize_resource

    def update
      if @transport_type.update(transport_type_params)
        redirect_to admin_transport_types_path, notice: 'Transport type was successfully updated.'
      else
        render :edit
      end
    end

    private

    def transport_type_params
      params.require(:transport_type).permit(:name, :image, :kg_co2e_per_km, :speed_km_per_hour, :can_share, :note)
    end
  end
end
