module Admin
  class ScoreboardsController < ApplicationController
    include LocaleHelper
    load_and_authorize_resource

    # GET /scoreboards
    def index
      @scoreboards = @scoreboards.order(:name)
    end

    def new; end

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
    rescue EnergySparks::SafeDestroyError => e
      redirect_to admin_scoreboards_path, alert: "Delete failed: #{e.message}"
    end

    private

    def scoreboard_params
      translated_params = t_params(Scoreboard.mobility_attributes)
      params.require(:scoreboard).permit(translated_params, :description, :academic_year_calendar_id, :public)
    end
  end
end
