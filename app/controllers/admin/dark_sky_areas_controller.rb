module Admin
  class DarkSkyAreasController < AdminController
    def index
      @dark_sky_areas = DarkSkyArea.all
    end

    def show
    end

    def new
    end

    def edit
    end

    def update
    end

    def create
    end
  end
end
