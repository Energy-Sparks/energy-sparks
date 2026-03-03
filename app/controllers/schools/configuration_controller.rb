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

      [:area_school_grouping_attributes, :diocese_school_grouping_attributes].each do |attributes|
        if params[:school][attributes]
          attrs = params[:school][attributes]

          if attrs[:school_group_id].blank?
            case attributes
            when :diocese_school_grouping_attributes
              @school.diocese_school_grouping&.destroy
            else
              @school.area_school_grouping&.destroy
            end

            params[:school].delete(attributes)
          end
        end
      end

      default_contract_holder_type = case school_params[:default_contract_holder_id]
                                     when '', nil
                                       nil
                                     when @school.id
                                       School
                                     else
                                       SchoolGroup
                                     end

      @school.update!(school_params.merge(default_contract_holder_type:))
      redirect_to school_path(@school)
    end

  private

    def set_school
      @school = School.friendly.find(params[:school_id])
      authorize! :configure, @school
    end

    def school_params
      params.require(:school).permit(
        :country,
        :dark_sky_area_id,
        :data_sharing,
        :default_contract_holder_id,
        :funder_id,
        :full_school,
        :local_authority_area_id,
        :region,
        :scoreboard_id,
        :solar_pv_tuos_area_id,
        :template_calendar_id,
        :weather_station_id,
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
