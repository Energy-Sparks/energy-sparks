# frozen_string_literal: true

class AlertsComponent < ViewComponent::Base
  attr_reader :school, :show_links, :show_icons

  def initialize(school:, dashboard_alerts:, alert_types:, show_links: true, show_icons: true)
    @school = school
    @dashboard_alerts = dashboard_alerts
    @alert_types = alert_types
    @show_links = show_links
    @show_icons = show_icons
  end

  def alerts
    @alerts ||= dashboard_alerts_for(@alert_types)
  end

  def dashboard_alerts_for(alert_types)
    alert_type_ids = alert_types.map(&:id)
    @dashboard_alerts.select { |dashboard_alert| alert_type_ids.include?(dashboard_alert.alert.alert_type_id) }
  end
end
