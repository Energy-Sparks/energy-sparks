# frozen_string_literal: true

module Schools
  class ProgrammesController < ApplicationController
    load_and_authorize_resource :school

    def create
      programme_type = ProgrammeType.find(params[:programme_type_id])
      Programmes::Creator.new(@school, programme_type).create
      redirect_to programme_type_path(programme_type)
    end
  end
end
