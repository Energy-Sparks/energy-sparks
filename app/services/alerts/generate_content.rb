module Alerts
  class GenerateContent
    def initialize(school)
      @school = school
    end

    def perform
      ActiveRecord::Base.transaction do
        ContentGenerationRun.create!(school: @school).tap do |content_generation_run|
          latest_alerts = @school.latest_alerts_without_exclusions.displayable

          Alerts::GenerateFindOutMores.new(content_generation_run: content_generation_run).perform(latest_alerts)
          Alerts::GenerateDashboardAlerts.new(content_generation_run: content_generation_run).perform(latest_alerts)
          Alerts::GenerateManagementPriorities.new(content_generation_run: content_generation_run).perform(latest_alerts)
          Alerts::GenerateAnalysisPages.new(content_generation_run: content_generation_run).perform(latest_alerts)
        end
      end
    end
  end
end
