module Schools
  class ProgrammeTypesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :programme_type

    def index
      @started_programmes = @school.programmes.active
      @available_programmes = ProgrammeType.active.where.not(id: @started_programmes.map(&:programme_type_id))
    end

    def show
    end
  end
end
