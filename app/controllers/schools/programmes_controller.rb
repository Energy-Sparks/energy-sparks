module Schools
  class ProgrammesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :programme, except: [:create]

    def create
      programme_type = ProgrammeType.find(params[:programme_type_id])
      Programmes::Creator.new(@school, programme_type).create
      redirect_to programme_type_path(programme_type)
    end

    def show
    end
  end
end
