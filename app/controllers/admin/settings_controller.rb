module Admin
  class SettingsController < AdminController
    before_action :load_site_settings

    def show
      @temperature_setting_months = temperature_setting_months
    end

    def update
      @settings.update!(site_settings_params)
      BenchmarkMetrics.set_current_prices(prices: SiteSettings.current_prices)
      redirect_to admin_settings_path, notice: 'Settings updated'
    end

  private

    def load_site_settings
      @settings = SiteSettings.current
    end

    def site_settings_params
      formatted_settings_params = settings_params
      SiteSettings.stored_attributes[:prices].each do |price_type|
        next unless settings_params[price_type]

        formatted_settings_params[price_type] = formatted_settings_params[price_type].to_f
      end
      formatted_settings_params
    end

    def settings_params
      params.require(:site_settings).permit(
        :message_for_no_contacts, :message_for_no_pupil_accounts,
        :management_priorities_dashboard_limit, :management_priorities_page_limit,
        :default_import_warning_days, :photo_bonus_points, :audit_activities_bonus_points,
        :electricity_price, :solar_export_price, :gas_price,
        temperature_recording_months: []
      )
    end

    def temperature_setting_months
      (1..12).map {|month| [Date::MONTHNAMES[month], month]}
    end
  end
end
