class ProgrammeTypesController < ApplicationController
  load_and_authorize_resource :programme_type
  skip_before_action :authenticate_user!, only: [:index, :show]

  before_action :load_programme_types

  def index
    @programme_types = @programme_types.active.by_title
  end

  def show
  end

  private

  def load_programme_types
    if current_user_school
      school_programme_type_ids = current_user_school.programmes.map(&:programme_type_id)
      @started_programmes = ProgrammeType.active.where(id: school_programme_type_ids).by_title
    else
      @started_programmes = []
    end
  end
end
