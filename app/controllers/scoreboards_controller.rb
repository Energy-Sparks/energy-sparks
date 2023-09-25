class ScoreboardsController < ApplicationController
  include Scoring

  load_resource
  skip_before_action :authenticate_user!

  # GET /scoreboards
  def index
    @scoreboards = ComparisonService.new(current_user).list_scoreboards
  end

  def show
    authorize! :read, @scoreboard
    setup_scores_and_years(@scoreboard)
  end
end
