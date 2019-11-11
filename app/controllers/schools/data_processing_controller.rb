module Schools
  class DataProcessingController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_data_processing, @school
      @school.update!(process_data: true)
      redirect_back fallback_location: school_path(@school)
    end

    def destroy
      authorize! :change_data_processing, @school
      @school.update!(process_data: false)
      redirect_back fallback_location: school_path(@school)
    end
  end
end
