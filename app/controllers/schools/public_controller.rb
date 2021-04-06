module Schools
  class PublicController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_public, @school
      @school.update!(public: true)
      redirect_back fallback_location: school_path(@school)
    end

    def destroy
      authorize! :change_public, @school
      @school.update!(public: false)
      redirect_back fallback_location: school_path(@school)
    end
  end
end
