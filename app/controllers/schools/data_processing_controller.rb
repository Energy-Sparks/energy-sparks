module Schools
  class DataProcessingController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_data_processing, @school
      @school.process_data!
      redirect_back fallback_location: school_path(@school), notice: "#{@school.name} will now process data"
    rescue School::ProcessDataError => e
      redirect_back fallback_location: school_path(@school), notice: e.message
    end

    def destroy
      authorize! :change_data_processing, @school
      @school.update!(process_data: false)
      redirect_back fallback_location: school_path(@school)
    end
  end
end
