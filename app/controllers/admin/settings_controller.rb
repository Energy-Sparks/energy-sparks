module Admin
  class SettingsController < AdminController
    def show
      @settings = SiteSettings.current
      @temperature_setting_months = temperature_setting_months
    end

    def update
      SiteSettings.create!(settings_params)
      redirect_to admin_settings_path, notice: 'Settings updated'
    end

  private

    def settings_params
      params.require(:site_settings).permit(
        :message_for_no_contacts, :message_for_no_pupil_accounts,
        :management_priorities_dashboard_limit, :management_priorities_page_limit,
        temperature_recording_months: []
      )
    end

    def temperature_setting_months
      (1..12).map {|month| [Date::MONTHNAMES[month], month]}
    end
  end
end
