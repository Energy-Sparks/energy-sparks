module Schools
  class ProgrammeTypesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :programme_type

    def show
      @can_start_programme = current_user.school && current_user.school.id == @school.id
    end
  end
end
