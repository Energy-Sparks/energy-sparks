class ScoreboardsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:show, :index]

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

  # GET /scoreboards/new
  def new
  end

  # GET /scoreboards/1/edit
  def edit
    @schools = @scoreboard.schools.order(:name)
  end

  # POST /scoreboards
  def create
    if @scoreboard.save
      redirect_to scoreboards_path, notice: 'Scoreboard was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /scoreboards/1
  def update
    if @scoreboard.update(scoreboard_params)
      redirect_to scoreboards_path, notice: 'Scoreboard was successfully updated.'
    else
      @schools = @scoreboard.schools.order(:name)
      render :edit
    end
  end

  # DELETE /scoreboards/1
  def destroy
    @scoreboard.safe_destroy
    redirect_to scoreboards_url, notice: 'Scoreboard deleted'
  rescue EnergySparks::SafeDestroyError => error
    redirect_to scoreboards_url, alert: "Delete failed: #{error.message}"
  end

private

  def scoreboard_params
    params.require(:scoreboard).permit(:name, :description, :academic_year_calendar_id)
  end
end
