module Admin
  class TransportTypesController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    def index
      @transport_types = @transport_types.by_position
    end

    def create
      if @transport_type.save
        redirect_to admin_transport_types_path, notice: 'Transport type was successfully created.'
      else
        render :new
      end
    end

    def update
      if @transport_type.update(transport_type_params)
        redirect_to admin_transport_types_path, notice: 'Transport type was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @transport_type.safe_destroy
      redirect_to admin_transport_types_path, notice: 'Transport type was successfully deleted.'
    rescue EnergySparks::SafeDestroyError => e
      redirect_to admin_transport_types_path, alert: "Delete failed: #{e.message}."
    end

    private

    def transport_type_params
      translated_params = t_params(TransportType.mobility_attributes)
      params.require(:transport_type).permit(translated_params, :name, :category, :image, :kg_co2e_per_km, :speed_km_per_hour, :can_share, :park_and_stride, :position, :note)
    end
  end
end
