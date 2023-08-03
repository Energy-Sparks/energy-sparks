module EnergyTariffable
  extend ActiveSupport::Concern

  def load_and_authorize_if_site_setting
    return unless request.path.start_with?('/admin/settings') || @energy_tariff&.tariff_holder_type == 'SiteSettings'
    if can?(:manage, :admin)
      @site_setting = SiteSettings.current
    else
      redirect_to new_user_session_path and return
    end
  end
end
