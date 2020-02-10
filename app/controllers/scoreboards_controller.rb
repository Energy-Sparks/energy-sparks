class ScoreboardsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!

  # GET /scoreboards
  def index
    @scoreboards = @scoreboards.order(:name)
  end

  def show
    @academic_year = if params[:academic_year]
                       @scoreboard.academic_year_calendar.academic_years.find(params[:academic_year])
                     else
                       @scoreboard.academic_year_calendar.academic_year_for(Time.zone.today)
                     end
    @active_academic_years = @scoreboard.active_academic_years
    @schools = @scoreboard.scored_schools(academic_year: @academic_year)
  end
end
