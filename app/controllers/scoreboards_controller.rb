class ScoreboardsController < ApplicationController
  load_resource
  skip_before_action :authenticate_user!

  # GET /scoreboards
  def index
    @scoreboards = ComparisonService.new(current_user).list_scoreboards
  end

  def show
    authorize! :read, @scoreboard
    @current_year = @scoreboard.current_academic_year
    @previous_year = @scoreboard.previous_academic_year

    @academic_year = if params[:academic_year]
                       @scoreboard.academic_year_calendar.academic_years.find(params[:academic_year])
                     else
                       @current_year
                     end
    @schools = @scoreboard.scored_schools(academic_year: @academic_year)
  end
end
