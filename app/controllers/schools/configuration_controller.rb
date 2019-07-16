# frozen_string_literal: true

module Schools
  class ConfigurationController < ApplicationController
    before_action :set_school

    def new
      if @school.school_group
        @school.calendar_area = @school.school_group.default_calendar_area
        @school.solar_pv_tuos_area = @school.school_group.default_solar_pv_tuos_area
        @school.weather_underground_area = @school.school_group.default_weather_underground_area
        @school.dark_sky_area = @school.school_group.default_dark_sky_area
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
        :calendar_area_id,
        :weather_underground_area_id,
        :solar_pv_tuos_area_id
      )
    end
  end
end
