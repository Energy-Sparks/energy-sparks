module Admin
  module SchoolOnboardings
    class ConfigurationController < AdminController
      load_and_authorize_resource :school_onboarding, find_by: :uuid

      def edit
      end

      def update
        @school_onboarding.update!(school_params)
        if @school_onboarding.has_event?(:email_sent)
          redirect_to admin_school_onboardings_path(anchor: @school_onboarding.page_anchor)
        else
          redirect_to new_admin_school_onboarding_email_path(@school_onboarding)
        end
      end

    private

      def school_params
        params.require(:school_onboarding).permit(
          :contract_id,
          :country,
          :dark_sky_area_id,
          :data_sharing,
          :default_chart_preference,
          :diocese_id,
          :funder_id,
          :local_authority_area_id,
          :project_group_id,
          :scoreboard_id,
          :template_calendar_id,
          :weather_station_id
        )
      end
    end
  end
end
