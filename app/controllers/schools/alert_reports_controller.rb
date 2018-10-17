# Warning - this pulls in statsample which seems to do something
# to array#sum - https://github.com/clbustos/statsample/issues/45
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
