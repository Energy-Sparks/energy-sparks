module Schools
  class VisibilityController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_visiblity, @school
      SchoolCreator.new(@school).make_visible!
      redirect_back fallback_location: school_path(@school)
    end

    def destroy
      authorize! :change_visiblity, @school
      @school.update!(visible: false)
      redirect_back fallback_location: school_path(@school)
    end
  end
end
