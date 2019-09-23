module Alerts
  class GenerateContent
    def initialize(school)
      @school = school
    end

    def perform(subscription_frequency: [])
      ActiveRecord::Base.transaction do
        ContentGenerationRun.create!(school: @school).tap do |content_generation_run|
          Alerts::GenerateFindOutMores.new(@school, content_generation_run: content_generation_run).perform
          Alerts::GenerateDashboardAlerts.new(@school, content_generation_run: content_generation_run).perform
          Alerts::GenerateManagementPriorities.new(@school, content_generation_run: content_generation_run).perform
          Alerts::GenerateSubscriptionEvents.new(@school, content_generation_run: content_generation_run).perform(frequency: subscription_frequency) if @school.active?
        end
      end
    end
  end
end
