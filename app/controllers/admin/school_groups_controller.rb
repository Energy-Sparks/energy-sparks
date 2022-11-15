module Admin
  class SchoolGroupsController < AdminController
    load_and_authorize_resource

    def index
      respond_to do |format|
        format.html { @school_groups = @school_groups.by_name }
        format.csv do
          send_data ::SchoolGroups::CsvGenerator.new(@school_groups.by_name).export_detail,
          filename: ::SchoolGroups::CsvGenerator.filename
        end
      end
    end

    def new
    end

    def edit
      @schools = @school_group.schools.by_name
    end

    def create
      if @school_group.save
        redirect_to admin_school_groups_path, notice: 'School group was successfully created.'
      else
        render :new
      end
    end

    def update
      if @school_group.update(school_group_params)
        redirect_to admin_school_groups_path, notice: 'School group was successfully updated.'
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
        :name, :description, :default_scoreboard_id,
        :default_template_calendar_id,
        :default_dark_sky_area_id,
        :default_solar_pv_tuos_area_id,
        :default_weather_station_id,
        :default_chart_preference,
        :default_notes_admin_user_id,
        :public
      )
    end
  end
end
