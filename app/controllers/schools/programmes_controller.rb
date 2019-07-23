module Schools
  class ProgrammesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :programme, except: [:create]

    def create
      programme_type = ProgrammeType.find(params[:programme_type_id])
      programme = Programmes::Creator.new(@school, programme_type).create
      redirect_to school_programme_path(@school, programme)
    end

    def show
    end
  end
end
