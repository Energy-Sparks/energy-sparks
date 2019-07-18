class ProgrammeTypesController < ApplicationController
  load_and_authorize_resource

  before_action :school?

  # GET /programme_types
  def index
  end

  # GET /
  def show
  end

  private

  def school?
    @school = current_user.school if current_user && current_user.school
  end

end
