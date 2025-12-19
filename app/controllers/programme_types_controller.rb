class ProgrammeTypesController < ApplicationController
  load_and_authorize_resource :programme_type
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @programme_types = @programme_types.active.by_title
  end

  def show
    route_not_found unless @programme_type.active && @programme_type.has_todos?
  end
end
