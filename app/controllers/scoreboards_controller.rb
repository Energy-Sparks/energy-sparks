class ScoreboardsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:show]

  # GET /scoreboards
  def index
    @scoreboards = @scoreboards.order(:name)
  end

  def show
    @schools = @scoreboard.scored_schools
  end

  # GET /scoreboards/new
  def new
  end

  # GET /scoreboards/1/edit
  def edit
    @school_groups = @scoreboard.school_groups.order(:name)
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
      @school_groups = @scoreboard.school_groups.order(:name)
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
    params.require(:scoreboard).permit(:name, :description, :calendar_area_id)
  end
end
