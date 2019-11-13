module Alerts
  class GenerateContent
    def initialize(school)
      @school = school
    end

    def perform(subscription_frequency: [])
      ActiveRecord::Base.transaction do
        ContentGenerationRun.create!(school: @school).tap do |content_generation_run|
          latest_alerts = @school.latest_alerts_without_exclusions.displayable
          latest_alerts_with_frequency = latest_alerts.joins(:alert_type).where(alert_types: { frequency: subscription_frequency })

          Alerts::GenerateFindOutMores.new(content_generation_run: content_generation_run).perform(latest_alerts)
          Alerts::GenerateDashboardAlerts.new(content_generation_run: content_generation_run).perform(latest_alerts)
          Alerts::GenerateManagementPriorities.new(content_generation_run: content_generation_run).perform(latest_alerts)
          Alerts::GenerateAnalysisPages.new(content_generation_run: content_generation_run).perform(latest_alerts)

          Alerts::GenerateSubscriptionEvents.new(@school, content_generation_run: content_generation_run).perform(latest_alerts_with_frequency) if @school.visible?
        end
      end
    end
  end
end
