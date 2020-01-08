module DashboardAlerts
  extend ActiveSupport::Concern

  def setup_alerts(alerts, content_field, limit: 3)
    alerts.includes(:content_version, :find_out_more).by_priority.limit(limit).map do |dashboard_alert|
      TemplateInterpolation.new(
        dashboard_alert.content_version,
        with_objects: {
          find_out_more: dashboard_alert.find_out_more,
          alert: dashboard_alert.alert,
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
