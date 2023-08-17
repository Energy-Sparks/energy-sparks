module EnergyTariffable
  extend ActiveSupport::Concern

  def build_breadcrumbs
    href = if @tariff_holder.school?
             school_path(@tariff_holder)
           elsif @tariff_holder.school_group?
             school_group_path(@tariff_holder)
           end
    @breadcrumbs = [
      { name: I18n.t('common.schools'), href: schools_path },
      { name: @tariff_holder.name, href: href },
      { name: t('schools.energy_tariff.title') }
    ]
  end

  def site_settings_resource?
    request.path.start_with?('/admin/settings') || @energy_tariff&.tariff_holder&.site_settings?
  end

  def load_site_setting
    @tariff_holder = SiteSettings.current if can?(:manage, :admin_functions)
  end
end
