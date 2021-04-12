module Admin
  class ScoreboardsController < ApplicationController
    load_and_authorize_resource

    # GET /scoreboards
    def index
      @scoreboards = @scoreboards.order(:name)
    end

    def new
    end

    def edit
      @schools = @scoreboard.schools.by_name
    end

    def create
      if @scoreboard.save
        redirect_to admin_scoreboards_path, notice: 'Scoreboard was successfully created.'
      else
        render :new
      end
    end

    def update
      if @scoreboard.update(scoreboard_params)
        redirect_to admin_scoreboards_path, notice: 'Scoreboard was successfully updated.'
      else
        @schools = @scoreboard.schools.by_name
        render :edit
      end
    end

    # DELETE /scoreboards/1
    def destroy
      @scoreboard.safe_destroy
      redirect_to admin_scoreboards_path, notice: 'Scoreboard deleted'
    rescue EnergySparks::SafeDestroyError => error
      redirect_to admin_scoreboards_path, alert: "Delete failed: #{error.message}"
    end

  private

    def scoreboard_params
      params.require(:scoreboard).permit(:name, :description, :academic_year_calendar_id, :public)
    end
  end
end
