module Schools
  class VisibilityController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_visibility, @school
      if @school.consent_grants.any?
        SchoolCreator.new(@school).make_visible!
      else
        flash[:notice] = "School cannot be made visible as we dont have a record of consent"
      end
      redirect_back fallback_location: school_path(@school)
    end

    def destroy
      authorize! :change_visibility, @school
      @school.update!(visible: false)
      redirect_back fallback_location: school_path(@school)
    end
  end
end
