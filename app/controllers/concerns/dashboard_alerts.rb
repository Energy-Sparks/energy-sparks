module DashboardAlerts
  extend ActiveSupport::Concern

  def setup_alerts(alerts, content_field, limit: 2)
    alerts.includes(:content_version, :find_out_more, :alert, { alert: [:alert_type, { alert_type: :advice_page }] }).by_priority.limit(limit).map do |dashboard_alert|
      TemplateInterpolation.new(
        dashboard_alert.content_version,
        with_objects: {
          advice_page: dashboard_alert.alert.alert_type.advice_page,
          alert: dashboard_alert.alert,
          alert_type: dashboard_alert.alert.alert_type,
          find_out_more: dashboard_alert.alert.alert_type.find_out_more?,
          priority: dashboard_alert.priority
        },
        proxy: [:colour]
      ).interpolate(
        content_field,
        with: dashboard_alert.alert.template_variables
      )
    end
  end
end
