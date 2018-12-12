require 'dashboard'

class Schools::AlertReportsController < ApplicationController
  load_and_authorize_resource :school

  def index
    authorize! :manage, Alert, school_id: @school.id
    @results = AlertGeneratorService.new(@school).perform
  end
end
