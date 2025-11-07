module Schools
  class ConfigurationController < ApplicationController
    before_action :set_school, :load_scoreboards

    layout 'dashboards'

    def new
      if @school.school_group
        @school.template_calendar = @school.school_group.default_template_calendar
        @school.solar_pv_tuos_area = @school.school_group.default_solar_pv_tuos_area
        @school.dark_sky_area = @school.school_group.default_dark_sky_area
        @school.weather_station = @school.school_group.default_weather_station
        @school.scoreboard = @school.school_group.default_scoreboard
      end
    end

    def create
      @school.update!(school_params)
      SchoolCreator.new(@school).process_new_configuration!
      redirect_to school_meters_path(@school)
    end

    def edit
    end

    def update
      @school.update!(school_params)
      redirect_to school_path(@school)
    end

  private

    def set_school
      @school = School.friendly.find(params[:school_id])
      authorize! :configure, @school
    end

    def school_params
      params.require(:school).permit(
        :template_calendar_id,
        :solar_pv_tuos_area_id,
        :dark_sky_area_id,
        :scoreboard_id,
        :school_group_id,
        :weather_station_id,
        :funder_id,
        :region,
        :local_authority_area_id,
        :country,
        :data_sharing
      )
    end

    def load_scoreboards
      @scoreboards = if @school.template_calendar
                       Scoreboard.where(academic_year_calendar_id: @school.template_calendar.based_on_id).order(:name)
                     else
                       Scoreboard.order(:name)
                     end
    end
  end
end
