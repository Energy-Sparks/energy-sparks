module Admin
  class SchoolGroupsController < AdminController
    load_and_authorize_resource

    def index
      @group_type = group_type
      @organisation_group = organisation_group?
      @school_groups = SchoolGroup.by_group_type(@group_type)
      respond_to do |format|
        format.html { @school_groups = @school_groups.by_name }
        format.csv do
          send_data ::SchoolGroups::CsvGenerator.new(@school_groups.by_name, include_total: @organisation_group).export_detail,
          filename: ::SchoolGroups::CsvGenerator.filename
        end
      end
    end

    def new
      redirect_to admin_path and return if ['diocese', 'local_authority_area'].include?(group_type)
      @school_group = SchoolGroup.build(group_type: group_type)
    end

    def edit
      @schools = @school_group.assigned_schools.by_name
    end

    def create
      if @school_group.save
        redirect_to admin_school_groups_path(group_type: @school_group.group_type), notice: 'School group was successfully created.'
      else
        render :new
      end
    end

    def update
      if @school_group.update(school_group_params)
        redirect_to admin_school_group_path(@school_group), notice: 'School group was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @school_group.safe_destroy
      redirect_to admin_school_groups_path, notice: 'School group deleted'
    rescue EnergySparks::SafeDestroyError => error
      redirect_to admin_school_groups_path, alert: "Delete failed: #{error.message}"
    end

  private

    def school_group_params
      params.require(:school_group).permit(
        :name, :description,
        :group_type,
        :default_country,
        :default_scoreboard_id,
        :default_template_calendar_id,
        :default_dark_sky_area_id,
        :default_weather_station_id,
        :default_chart_preference,
        :default_issues_admin_user_id,
        :public,
        :admin_meter_statuses_electricity_id,
        :admin_meter_statuses_gas_id,
        :admin_meter_statuses_solar_pv_id,
        :default_data_source_electricity_id,
        :default_data_source_gas_id,
        :default_data_source_solar_pv_id,
        :default_procurement_route_electricity_id,
        :default_procurement_route_gas_id,
        :default_procurement_route_solar_pv_id,
      )
    end

    def group_type
      params[:group_type] || 'multi_academy_trust'
    end

    def organisation_group?
      SchoolGroup::ORGANISATION_GROUP_TYPE_KEYS.include?(group_type)
    end
  end
end
