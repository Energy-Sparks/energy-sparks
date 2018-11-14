class ScoreboardsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:show]
  before_action :set_scoreboard, only: [:show, :edit, :update, :destroy]
  before_action :award_player_badge, only: [:show]

  # GET /scoreboards
  def index
    @scoreboards = Scoreboard.order(:name)
  end

  def show
    @schools = @scoreboard.scored_schools
  end

  # GET /scoreboards/new
  def new
    @scoreboard = Scoreboard.new
  end

  # GET /scoreboards/1/edit
  def edit
    @school_groups = @scoreboard.school_groups.order(:name)
  end

  # POST /scoreboards
  def create
    @scoreboard = Scoreboard.new(scoreboard_params)
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

  def set_scoreboard
    @scoreboard = Scoreboard.friendly.find(params[:id])
  end

  def scoreboard_params
    params.require(:scoreboard).permit(:name, :description)
  end

  def award_player_badge
    if current_user && current_user.enrolled_school_admin?
      school = current_user.school
      if @scoreboard.schools.include?(school) && school.points >= 10
        badge = Merit::Badge.find_by_name_and_level('player', nil)
        school.add_badge(badge.id)
      end
    end
  end
end
