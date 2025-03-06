module Schools
  class PublicController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_public, @school
      @school.update!(public: true, data_sharing: :public)
      redirect_back fallback_location: school_path(@school)
    end

    def destroy
      authorize! :change_public, @school
      @school.update!(public: false, data_sharing: :within_group)
      redirect_back fallback_location: school_path(@school)
    end
  end
end
