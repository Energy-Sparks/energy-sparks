module EnergyTariffable
  extend ActiveSupport::Concern

  def build_breadcrumbs
    @breadcrumbs = []
    if @tariff_holder.school_group?
      @breadcrumbs += [
        { name: I18n.t('common.schools'), href: schools_path },
        { name: @tariff_holder.name, href: school_group_path(@tariff_holder) }
      ]
    end
    if request.path.ends_with?('energy_tariffs')
      @breadcrumbs << { name: t('schools.energy_tariffs.title') }
    else
      @breadcrumbs << { name: t('schools.energy_tariffs.title'), href: polymorphic_path([@tariff_holder, :energy_tariffs]) }
      @breadcrumbs << { name: @page_title }
    end
  end

  def set_page_title
    @page_title = t("schools.#{controller_name.gsub('energy_tariff', 'user_tariff')}.#{action_name}.breadcrumb_title", default: action_name, name: @energy_tariff&.name)
  end

  def site_settings_resource?
    request.path.start_with?('/admin/settings') || @energy_tariff&.tariff_holder&.site_settings?
  end

  def load_site_setting
    @tariff_holder = SiteSettings.current if can?(:manage, :admin_functions)
  end
end
