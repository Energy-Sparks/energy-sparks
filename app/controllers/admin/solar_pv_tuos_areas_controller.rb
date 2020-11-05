module Admin
  class SolarPvTuosAreasController < AdminController
    load_and_authorize_resource

    def index
    end

    def new
    end

    def create
      if @solar_pv_tuos_area.save
        redirect_to admin_solar_pv_tuos_areas_path, notice: 'New Solar PV Area created. Data will be back filled overnight.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @solar_pv_tuos_area.update(solar_pv_tuos_area_params)
        @solar_pv_tuos_area.solar_pv_tuos_readings.delete_all if lat_long_changed?
        redirect_to admin_solar_pv_tuos_areas_path, notice: 'Solar PV Area was updated.'
      else
        render :edit
      end
    end

    private

    def lat_long_changed?
      changes = @solar_pv_tuos_area.previous_changes
      changes.key?(:latitude) || changes.key?(:longitude)
    end

    def solar_pv_tuos_area_params
      params.require(:solar_pv_tuos_area).permit(:title, :latitude, :longitude, :back_fill_years)
    end
  end
end
