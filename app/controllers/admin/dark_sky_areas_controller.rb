module Admin
  class DarkSkyAreasController < AdminController
    load_and_authorize_resource

    def index
    end

    def new
    end

    def create
      if @dark_sky_area.save
        redirect_to admin_dark_sky_areas_path, notice: 'New Dark Sky Area created. Overnight the 4 years of data for this new area will be back filled.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @dark_sky_area.update(dark_sky_area_params)
        @dark_sky_area.dark_sky_temperature_readings.delete_all if lat_long_changed?
        redirect_to admin_dark_sky_areas_path, notice: 'Dark Sky Area was updated.'
      else
        render :edit
      end
    end

    private

    def lat_long_changed?
      changes = @dark_sky_area.previous_changes
      changes.key?(:latitude) || changes.key?(:longitude)
    end

    def dark_sky_area_params
      params.require(:dark_sky_area).permit(:title, :description, :latitude, :longitude)
    end
  end
end
