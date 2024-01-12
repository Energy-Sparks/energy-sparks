class ScoreboardsController < ApplicationController
  include Scoring

  skip_before_action :authenticate_user!

  # GET /scoreboards
  def index
    @scoreboard_all = NationalScoreboard.new
    @scoreboards = ComparisonService.new(current_user).list_scoreboards
  end

  def show
    case params[:id]
    when 'all'
      redirect_to(action: 'show', id: NationalScoreboard::SLUG)
      return
    when NationalScoreboard::SLUG
      @scoreboard = NationalScoreboard.new
    else
      @scoreboard = Scoreboard.find(params[:id])
      authorize!(:read, @scoreboard)
    end
    setup_scores_and_years(@scoreboard)
  end
end
