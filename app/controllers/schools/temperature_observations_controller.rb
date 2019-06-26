module Schools
  class TemperatureObservationsController < ApplicationController
    load_resource :school
    load_and_authorize_resource :observation, through: :school, parent: false

    skip_before_action :authenticate_user!, only: [:index, :show]
    before_action :set_location_names, only: [:new, :create]

    def new
      10.times.each { @observation.temperature_recordings.build(location: Location.new) }
    end

    def create
      @observation.observation_type = :temperature
      if @observation.save
        redirect_to school_temperature_observations_path(@school)
      else
        render :new
      end
    end

    def show
    end

    def index
      @locations = @school.locations.order(name: :asc)
    end

    def destroy
      @observation.destroy
      redirect_to school_temperature_observations_path(@school), notice: 'Successfully deleted.'
    end

  private

    def set_location_names
      @location_names = @school.locations.pluck(:name).push('').join(',')
    end

    def observation_params
      params.require(:observation).permit(:description, :at, temperature_recordings_attributes: [:id, :centigrade, location_attributes: [:name, :school_id]])
    end
  end
end
