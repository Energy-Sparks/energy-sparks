module Schools
  class ActivationController < ApplicationController
    def create
      school = School.friendly.find(params[:school_id])
      authorize! :activate, school
      SchoolCreator.new(school).activate_school!
      redirect_back fallback_location: school_path(school)
    end
  end
end
