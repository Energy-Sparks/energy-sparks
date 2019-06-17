module Schools
  class ObservationsController < ApplicationController
    load_resource :school
    load_and_authorize_resource through: :school

    skip_before_action :authenticate_user!, only: [:index, :show]
    before_action :set_location_names, only: [:new, :create]

    def new
      @observation = @school.observations.build
      @location_names = @school.locations.pluck(:name)

      10.times.each { @observation.temperature_recordings.build(location: Location.new) }
    end

    def create
      @observation = process_locations(@observation)

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

    def set_location_names
      @location_names = @school.locations.pluck(:name).join(',')
    end

    def process_locations(observation)
      observation.temperature_recordings.each do |temperature_recording|
        location = temperature_recording.location
        existing_location = @school.locations.find_by(name: location.name)
        temperature_recording.location = existing_location if existing_location.present?
      end
      observation
    end

    def observation_params
      params.require(:observation).permit(:school_id, :description, :at, temperature_recordings_attributes: [:id, :centigrade, location_attributes: [:id, :name, :school_id]])
    end
  end
end
