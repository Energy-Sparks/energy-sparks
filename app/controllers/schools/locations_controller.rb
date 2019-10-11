module Schools
  class LocationsController < ApplicationController
    load_resource :school
    load_and_authorize_resource :location, through: :school, parent: false

    def index
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @location.save
        redirect_to school_locations_path(@school), notice: 'Location created'
      else
        render :new
      end
    end

    def update
      if @location.update(location_params)
        redirect_to school_locations_path(@school), notice: 'Location updated'
      else
        render :new
      end
    end

    def destroy
      @location.destroy
      redirect_back fallback_location: school_locations_path(@school), notice: 'Successfully deleted.'
    end

  private

    def location_params
      params.require(:location).permit(:description, :name, :school_id)
    end
  end
end
