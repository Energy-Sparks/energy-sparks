module Schools
  class VisibilityController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_visibility, @school
      SchoolCreator.new(@school).make_visible!
      redirect_back fallback_location: school_path(@school)
    rescue SchoolCreator::Error => e
      redirect_back fallback_location: school_path(@school), notice: e.message
    end

    def destroy
      authorize! :change_visibility, @school
      @school.update!(visible: false)
      redirect_back fallback_location: school_path(@school)
    end
  end
end
