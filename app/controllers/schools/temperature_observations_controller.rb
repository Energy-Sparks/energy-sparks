module Schools
  class TemperatureObservationsController < ApplicationController
    load_resource :school
    load_and_authorize_resource :observation, through: :school, parent: false

    skip_before_action :authenticate_user!, only: [:index, :show]
    before_action :set_location_names, only: [:new, :create]
    before_action :set_inital_recording_count, only: [:new, :create]

    TEMPERATURE_RECORD_INCREASE = 10

    def new
      @locations = @school.locations.order(name: :asc)
      @locations.each { |location| @observation.temperature_recordings.build(location: location) }
      if params[:introduction]
        render :introduction
      else
        render :new
      end
    end

    def create
      if TemperatureObservationCreator.new(@observation).process
        redirect_to school_temperature_observations_path(@school)
      else
        render :new
      end
    end

    def show
    end

    def index
      @locations = @school.locations.order(name: :asc)
      @observations = @observations.temperature.visible.order('at DESC')
    end

    def destroy
      ObservationRemoval.new(@observation).process
      redirect_back fallback_location: school_temperature_observations_path(@school), notice: 'Successfully deleted.'
    end

  private

    def set_inital_recording_count
      @existing_location_count = @school.locations.count
      @locations_to_show_count = @existing_location_count + TEMPERATURE_RECORD_INCREASE
      @total_location_fields = @locations_to_show_count + TEMPERATURE_RECORD_INCREASE
    end

    def set_location_names
      @location_names = @school.locations.pluck(:name).push('').join(',')
    end

    def observation_params
      params.require(:observation).permit(:description, :at, temperature_recordings_attributes: [:id, :centigrade, :location_id])
    end
  end
end
