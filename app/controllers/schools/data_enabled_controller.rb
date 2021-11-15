module Schools
  class DataEnabledController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_data_enabled, @school
      @school.update!(data_enabled: true)
      redirect_back fallback_location: school_path(@school), notice: "#{@school.name} data is now visible"
    end

    def destroy
      authorize! :change_data_enabled, @school
      @school.update!(data_enabled: false)
      redirect_back fallback_location: school_path(@school)
    end
  end
end
