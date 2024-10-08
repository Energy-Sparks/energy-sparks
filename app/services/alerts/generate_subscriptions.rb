module Alerts
  class GenerateSubscriptions
    def initialize(school)
      @school = school
    end

    def perform(subscription_frequency: [])
      subscription_generation_run = SubscriptionGenerationRun.create!(school: @school)
      ActiveRecord::Base.transaction do
        latest_alerts = @school.latest_alerts_without_exclusions.displayable
        latest_alerts_with_frequency = latest_alerts.joins(:alert_type).where(alert_types: { frequency: subscription_frequency })
        Alerts::GenerateSubscriptionEvents.new(@school, subscription_generation_run: subscription_generation_run).perform(latest_alerts_with_frequency)
      end
      email_service = Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run)
      if Flipper.enabled?(:batch_send_weekly_alerts)
        email_service.batch_send
      else
        email_service.perform
      end

      Alerts::GenerateSmsNotifications.new(subscription_generation_run: subscription_generation_run).perform
    end
  end
end
