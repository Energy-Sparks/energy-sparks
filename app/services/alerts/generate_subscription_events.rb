module Alerts
  class GenerateSubscriptionEvents
    def initialize(school)
      @school = school
    end

    def perform
      @school.alerts.latest.each do |alert|
        subscriptions = @school.alert_subscriptions.where(alert_type: alert.alert_type)
        if subscriptions.any?
          subscriptions.each do |subscription|
            subscription.contacts.each do |contact|
              AlertSubscriptionEvent.where(contact: contact, alert: alert, alert_subscription: subscription).first_or_create
            end
          end
        end
      end
    end
  end
end


#  alert_type_id :bigint(8)
#  id            :bigint(8)        not null, primary key
#  school_id     :bigint(8)



#
#  alert_id              :bigint(8)
#  alert_subscription_id :bigint(8)
#  contact_id            :bigint(8)
#  created_at            :datetime         not null
#  id                    :bigint(8)        not null, primary key
#  message               :text
#  status                :integer          default("pending"), not null
#  updated_at            :datetime         not null
#
# Indexes
