require 'dashboard'

class Schools::AlertReportsController < ApplicationController
  load_and_authorize_resource :school, find_by: :slug
  skip_before_action :authenticate_user!
  before_action :set_school

  def index
    @results = AlertGeneratorService.new(@school).perform
  end

private

  def set_school
    @school = School.find(params[:school_id])
  end
end
