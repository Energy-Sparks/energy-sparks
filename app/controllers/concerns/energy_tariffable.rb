module EnergyTariffable
  extend ActiveSupport::Concern

  def load_and_authorize_if_site_setting
    return unless request.path.start_with?('/admin/settings') || @energy_tariff&.tariff_holder_type == 'SiteSettings'
    if can?(:manage, :admin_functions)
      @site_setting = SiteSettings.current
    else
      flash[:error] = "You are not authorized to view that page."
      redirect_to root_path
    end
  end
end
