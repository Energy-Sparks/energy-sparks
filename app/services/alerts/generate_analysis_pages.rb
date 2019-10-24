module Alerts
  class GenerateAnalysisPages
    def initialize(content_generation_run:)
      @content_generation_run = content_generation_run
    end

    def perform(alerts)
      alerts.each do |alert|
        FetchContent.new(alert).content_versions(scope: :analysis).each do |content_version|
          @content_generation_run.analysis_pages.create!(alert: alert, content_version: content_version, category: alert.alert_type.sub_category)
        end
      end
      @content_generation_run.analysis_pages
    end
  end
end
