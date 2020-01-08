module Admin
  class DarkSkyAreasController < AdminController
    load_and_authorize_resource

    def index
    end

    def show
    end

    def new
    end

    def create
      if @dark_sky_area.save
        redirect_to admin_dark_sky_areas_path, notice: 'New Dark Sky Area created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @dark_sky_area.update(dark_sky_area_params)
        redirect_to admin_dark_sky_areas_path, notice: 'Dark Sky Area was updated.'
      else
        render :edit
      end
    end

    private

    def dark_sky_area_params
      params.require(:dark_sky_area).permit(:title, :description, :latitude, :longitude)
    end
  end
end
