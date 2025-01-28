class ProgrammeTypesController < ApplicationController
  load_and_authorize_resource :programme_type
  skip_before_action :authenticate_user!, only: [:index, :show]

  before_action :user_progress

  def index
    @programme_types = @programme_types.active.by_title
  end

  def show
    if Flipper.enabled?(:todos)
      route_not_found unless @programme_type.active && @programme_type.has_todos?
    else
      route_not_found unless @programme_type.active
    end
  end

  private

  def user_progress
    if !Flipper.enabled?(:todos) || Flipper.enabled?(:todos_old)
      @user_progress = Programmes::UserProgress.new(current_user)
    end
  end
end
