module Alerts
  class GenerateContent
    def initialize(school)
      @school = school
    end

    def perform(subscription_frequency: [])
      ActiveRecord::Base.transaction do
        ContentGenerationRun.create!(school: @school).tap do |content_generation_run|
          Alerts::GenerateFindOutMores.new(@school).perform(content_generation_run: content_generation_run)
          Alerts::GenerateDashboardAlerts.new(@school).perform(content_generation_run: content_generation_run)
          Alerts::GenerateSubscriptionEvents.new(@school).perform(frequency: subscription_frequency, content_generation_run: content_generation_run)
        end
      end
    end
  end
end
