class ProgrammeTypesController < ApplicationController
  load_and_authorize_resource :programme_type
  skip_before_action :authenticate_user!, only: [:index, :show]

  before_action :user_progress

  def index
    @programme_types = @programme_types.active.by_title
  end

  def show
  end

  private

  def user_progress
    @user_progress = Programmes::UserProgress.new(current_user)
  end
end
