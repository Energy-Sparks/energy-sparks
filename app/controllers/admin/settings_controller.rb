module Admin
  class SettingsController < AdminController
    def show
      @settings = SiteSettings.current
      @temperature_setting_months = temperature_setting_months
    end

    def update
      SiteSettings.create!(site_settings_params)
      if EnergySparks::FeatureFlags.active?(:use_site_settings_current_prices)
        BenchmarkMetrics.set_current_prices(prices: SiteSettings.current_prices)
      end
      redirect_to admin_settings_path, notice: 'Settings updated'
    end

  private

    def site_settings_params
      formatted_settings_params = settings_params
      SiteSettings.stored_attributes[:prices].each do |price_type|
        next unless settings_params[price_type]

        formatted_settings_params[price_type] = formatted_settings_params[price_type].to_f
      end
      formatted_settings_params
    end

    def settings_params
      if EnergySparks::FeatureFlags.active?(:use_site_settings_current_prices)
        params.require(:site_settings).permit(
          :message_for_no_contacts, :message_for_no_pupil_accounts,
          :management_priorities_dashboard_limit, :management_priorities_page_limit,
          :electricity_price, :solar_export_price, :gas_price, :oil_price,
          temperature_recording_months: []
        )
      else
        params.require(:site_settings).permit(
          :message_for_no_contacts, :message_for_no_pupil_accounts,
          :management_priorities_dashboard_limit, :management_priorities_page_limit,
          temperature_recording_months: []
        )
      end
    end

    def temperature_setting_months
      (1..12).map {|month| [Date::MONTHNAMES[month], month]}
    end
  end
end
