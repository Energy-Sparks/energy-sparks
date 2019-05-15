module Alerts
  class GenerateDashboardAlerts
    def initialize(school)
      @school = school
    end

    def perform(content_generation_run: nil)
      ActiveRecord::Base.transaction do
        content_generation_run ||= ContentGenerationRun.create!(school: @school)
        @school.alerts.latest.each do |alert|
          process_dashboard_alerts(alert, content_generation_run, :teacher)
          process_dashboard_alerts(alert, content_generation_run, :pupil)
        end
        content_generation_run.dashboard_alerts
      end
    end

  private

    def process_dashboard_alerts(alert, content_generation_run, dashboard)
      FetchContent.new(alert).content_versions(scope: :"#{dashboard}_dashboard_alert").each do |content_version|
        find_out_more = content_generation_run.find_out_mores.where(content_version: content_version).first
        content_generation_run.dashboard_alerts.create!(alert: alert, content_version: content_version, dashboard: dashboard, find_out_more: find_out_more)
      end
    end
  end
end
