module Alerts
  class GenerateManagementDashboardTables
    def initialize(content_generation_run:)
      @content_generation_run = content_generation_run
    end

    def perform(alerts)
      alerts.each do |alert|
        FetchContent.new(alert).content_versions(scope: :management_dashboard_table).each do |content_version|
          @content_generation_run.management_dashboard_tables.create!(alert: alert, content_version: content_version)
        end
      end
      @content_generation_run.management_dashboard_tables
    end
  end
end
