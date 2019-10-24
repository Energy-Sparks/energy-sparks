module Alerts
  class GenerateDashboardAlerts
    def initialize(content_generation_run:)
      @content_generation_run = content_generation_run
    end

    def perform(alerts)
      alerts.each do |alert|
        process_dashboard_alerts(alert, :teacher)
        process_dashboard_alerts(alert, :pupil)
        process_dashboard_alerts(alert, :public)
        process_dashboard_alerts(alert, :management)
      end
      @content_generation_run.dashboard_alerts
    end

  private

    def process_dashboard_alerts(alert, dashboard)
      FetchContent.new(alert).content_versions(scope: :"#{dashboard}_dashboard_alert").each do |content_version|
        find_out_more = @content_generation_run.find_out_mores.where(content_version: content_version).first
        @content_generation_run.dashboard_alerts.create!(alert: alert, content_version: content_version, dashboard: dashboard, find_out_more: find_out_more, priority: content_version.analysis_weighting)
      end
    end
  end
end
