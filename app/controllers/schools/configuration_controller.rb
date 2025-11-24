module Schools
  class ConfigurationController < ApplicationController
    before_action :set_school, :load_scoreboards

    layout 'dashboards'

    def edit
      @school.build_organisation_school_grouping unless @school.organisation_school_grouping
      @school.build_diocese_school_grouping unless @school.diocese_school_grouping
      @school.build_area_school_grouping unless @school.area_school_grouping
    end

    def update
      if (grouping_attrs = params[:school][:organisation_school_grouping_attributes])
        @school.school_group_id = grouping_attrs[:school_group_id]
      end
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
        :weather_station_id,
        :funder_id,
        :region,
        :local_authority_area_id,
        :country,
        :data_sharing,
        organisation_school_grouping_attributes: [:school_group_id],
        diocese_school_grouping_attributes: [:school_group_id],
        area_school_grouping_attributes: [:school_group_id],
        project_group_ids: []
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
