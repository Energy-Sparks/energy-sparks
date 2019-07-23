module Schools
  class ProgrammeTypesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :programme_type

    def show
    end
  end
end
