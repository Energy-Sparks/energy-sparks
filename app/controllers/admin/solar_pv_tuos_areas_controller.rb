module Admin
  class SolarPvTuosAreasController < AdminController
    load_and_authorize_resource

    def index
    end

    def show
    end

    def new
    end

    def create
      if @solar_pv_tuos_area.save
        redirect_to admin_solar_pv_tuos_areas_path, notice: 'New Solar PV Area created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @solar_pv_tuos_area.update(solar_pv_tuos_area_params)
        redirect_to admin_solar_pv_tuos_areas_path, notice: 'Solar PV Area was updated.'
      else
        render :edit
      end
    end

    def destroy
      @solar_pv_tuos_area.destroy
      redirect_to admin_solar_pv_tuos_areas_path, notice: 'Solar PV Area deleted'
    end

    private

    def solar_pv_tuos_area_params
      params.require(:solar_pv_tuos_area).permit(:title, :description, :latitude, :longitude)
    end
  end
end
