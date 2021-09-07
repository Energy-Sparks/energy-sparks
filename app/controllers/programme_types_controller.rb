class ProgrammeTypesController < ApplicationController
  load_and_authorize_resource :programme_type
  skip_before_action :authenticate_user!, only: [:index, :show]

  before_action :load_programme_types

  def index
    @programme_types = @programme_types.active
  end

  def show
  end

  private

  def load_programme_types
    if current_user_school
      @started = current_user_school.programmes.active
      @started_programmes = ProgrammeType.active.where(id: @started.map(&:programme_type_id))
      @available_programmes = ProgrammeType.active.where.not(id: @started.map(&:programme_type_id))
    end
  end
end
