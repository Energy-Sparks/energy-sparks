class ScoreboardsController < ApplicationController
  include Scoring

  skip_before_action :authenticate_user!

  # GET /scoreboards
  def index
    @scoreboard_all = ScoreboardAll.new
    @scoreboards = ComparisonService.new(current_user).list_scoreboards
  end

  def show
    if params[:id] == ScoreboardAll::SLUG
      @scoreboard = ScoreboardAll.new
    else
      @scoreboard = Scoreboard.find(params[:id])
      authorize!(:read, @scoreboard)
    end
    setup_scores_and_years(@scoreboard)
  end
end
