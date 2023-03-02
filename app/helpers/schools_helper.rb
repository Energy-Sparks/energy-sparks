module SchoolsHelper
  include Measurements

  def kid_date(date)
    date.strftime('%A, %d %B %Y')
  end

  def colours_for_supply(supply)
    supply == "electricity" ? %w(#3bc0f0 #232b49) : %w(#ffac21 #ff4500)
  end

  def meter_display_name(mpan_mprn)
    return mpan_mprn if mpan_mprn == "all"
    meter = Meter.find_by_mpan_mprn(mpan_mprn)
    meter.present? ? meter.display_name : meter
  end

  def disabled_for_pseudo_meter?(meter)
    meter.pseudo && action_name == 'edit'
  end

  def advice_page_path_from_alert_type(school, alert_type)
    advice_page = alert_type.advice_page
    polymorphic_path(
      [alert_type.advice_page_tab_for_link_to, school, :advice, advice_page.key.to_sym],
      anchor: alert_type.link_to_section
    )
  end

  def dashboard_alert_buttons(school, alert_content)
    if EnergySparks::FeatureFlags.active?(:replace_find_out_mores)
      alert_type = alert_content.alert.alert_type
      return {} unless alert_type.advice_page.present?
      { t('schools.show.find_out_more') => advice_page_path_from_alert_type(school, alert_type) }
    else
      return {} unless alert_content.find_out_more.present?
      { t('schools.show.find_out_more') => school_find_out_more_path(school, alert_content.find_out_more) }
    end
  end
end
