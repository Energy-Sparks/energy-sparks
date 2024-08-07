class GenerateSubscriptionsJob < ApplicationJob
  queue_as :regeneration

  def perform(school_id:)
    school = School.find(school_id)
    Alerts::GenerateSubscriptions.new(school).perform(subscription_frequency: school.subscription_frequency)
  end
end
