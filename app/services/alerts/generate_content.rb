module Alerts
  class GenerateContent
    def initialize(school)
      @school = school
    end

    def perform(subscription_frequency: [])
      ActiveRecord::Base.transaction do
        ContentGenerationRun.create!(school: @school).tap do |content_generation_run|
          latest_alerts = @school.alerts.latest
          latest_alerts_with_frequency = @school.alerts.joins(:alert_type).where(alert_types: { frequency: subscription_frequency }).latest

          Alerts::GenerateFindOutMores.new(content_generation_run: content_generation_run).perform(latest_alerts)
          Alerts::GenerateDashboardAlerts.new(content_generation_run: content_generation_run).perform(latest_alerts)
          Alerts::GenerateManagementPriorities.new(content_generation_run: content_generation_run).perform(latest_alerts)

          Alerts::GenerateSubscriptionEvents.new(@school, content_generation_run: content_generation_run).perform(latest_alerts_with_frequency) if @school.active?
        end
      end
    end
  end
end
