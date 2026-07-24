module SchoolsHelper
  include Measurements

  def kid_date(date)
    date.strftime('%A, %d %B %Y')
  end

  def meter_display_name(mpan_mprn)
    return mpan_mprn if mpan_mprn == 'all'
    meter = Meter.find_by_mpan_mprn(mpan_mprn)
    meter.present? ? meter.display_name : meter
  end

  def disabled_for_pseudo_meter?(meter)
    meter.pseudo && action_name == 'edit'
  end

  def dashboard_alert_buttons(school, alert_content)
    path = find_out_more_path_from_alert_content(school, alert_content)
    return {} if path.nil?
    { t('schools.show.find_out_more') => path }
  end

  # Switches between linking to the old find out more pages and the
  # new advice pages.
  def find_out_more_path_from_alert_content(school, alert_content, params: {}, mailer: false)
    alert_type = alert_content.alert.alert_type
    return nil unless alert_type.advice_page.present?
    advice_page_path_from_alert_type(school, alert_type, params: params, mailer: mailer)
  end

  def advice_page_path_from_alert_type(school, alert_type, params: {}, mailer: false)
    advice_page = alert_type.advice_page
    path_segments = [alert_type.advice_page_tab_for_link_to, school, :advice, advice_page.key.to_sym]
    if mailer
      polymorphic_url(path_segments, params.merge(anchor: alert_type.link_to_section))
    else
      polymorphic_path(path_segments, params.merge(anchor: alert_type.link_to_section))
    end
  end

  def data_sharing_colour(school)
    case school.data_sharing.to_sym
    when :public
      'text-bg-success'
    when :private
      'text-bg-danger'
    else
      'text-bg-warning'
    end
  end
end
