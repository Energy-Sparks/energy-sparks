# frozen_string_literal: true

module Schools
  class DeactivationController < ApplicationController
    def create
      school = School.friendly.find(params[:school_id])
      authorize! :deactivate, school
      school.update!(active: false)
      redirect_back fallback_location: school_path(school)
    end
  end
end
