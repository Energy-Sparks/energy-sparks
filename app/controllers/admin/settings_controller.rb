module Admin
  class SettingsController < AdminController
    def show
      @settings = SiteSettings.current
    end

    def update
      SiteSettings.create!(settings_params)
    end

  private

    def settings_params
      params.require(:site_settings).permit(:message_for_no_contacts)
    end
  end
end
