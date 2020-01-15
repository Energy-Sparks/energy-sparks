module Admin
  module SchoolOnboardings
    class ConfigurationController < AdminController
      load_and_authorize_resource :school_onboarding, find_by: :uuid

      def edit
        if @school_onboarding.school_group
          @school_onboarding.template_calendar = @school_onboarding.school_group.default_template_calendar
          @school_onboarding.solar_pv_tuos_area = @school_onboarding.school_group.default_solar_pv_tuos_area
          @school_onboarding.dark_sky_area = @school_onboarding.school_group.default_dark_sky_area
          @school_onboarding.scoreboard = @school_onboarding.school_group.default_scoreboard
        end
      end

      def update
        @school_onboarding.update!(school_params)
        redirect_to new_admin_school_onboarding_email_path(@school_onboarding)
      end

    private

      def school_params
        params.require(:school_onboarding).permit(
          :template_calendar_id,
          :solar_pv_tuos_area_id,
          :dark_sky_area_id,
          :scoreboard_id
        )
      end
    end
  end
end
