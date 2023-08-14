module EnergyTariffable
  extend ActiveSupport::Concern

  def site_settings_resource?
    request.path.start_with?('/admin/settings') || @energy_tariff&.site_settings_tariff_holder?
  end

  def load_site_setting
    @tariff_holder = SiteSettings.current if can?(:manage, :admin_functions)
  end
end
