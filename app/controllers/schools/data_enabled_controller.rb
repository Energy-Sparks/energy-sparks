module Schools
  class DataEnabledController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_data_enabled, @school
      SchoolCreator.new(@school).make_data_enabled!
      redirect_back fallback_location: school_path(@school), notice: "#{@school.name} is now data enabled"
    end

    def destroy
      authorize! :change_data_enabled, @school
      @school.update!(data_enabled: false)
      redirect_back fallback_location: school_path(@school)
    end
  end
end
