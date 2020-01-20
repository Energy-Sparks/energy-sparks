module Schools
  class DataProcessingController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_data_processing, @school
      if @school.meters_with_readings.any?
        @school.update!(process_data: true)
        redirect_back fallback_location: school_path(@school), notice: "#{@school.name} will now process data"
      else
        redirect_back fallback_location: school_path(@school), notice: "#{@school.name} cannot process data as it has no meter readings"
      end
    end

    def destroy
      authorize! :change_data_processing, @school
      @school.update!(process_data: false)
      redirect_back fallback_location: school_path(@school)
    end
  end
end
