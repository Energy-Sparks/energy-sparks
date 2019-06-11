module Schools
  class ObservationsController < ApplicationController
    load_resource :school
    load_and_authorize_resource through: :school

    skip_before_action :authenticate_user!, only: [:index, :show]

    def new
      @observation = @school.observations.build

      10.times.each { @observation.temperature_recordings.build(location: Location.new) }
    end

    def create
      if @observation.save
        redirect_to school_observations_path(@school)
      else
        render :new
      end
    end

    def show
    end

    def index
    end

  private

    def observation_params
      params.require(:observation).permit(:school_id, :description, :at, temperature_recordings_attributes: [:id, :centigrade, location_attributes: [:id, :name, :school_id]])
    end
  end
end
