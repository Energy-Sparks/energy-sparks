module Alerts
  class GenerateSubscriptionEvents
    def initialize(school, alert)
      @school = school
      @alert = alert
    end

    def perform
      subscriptions(@school, @alert.alert_type).each do |subscription|
        subscription.contacts.each do |contact|
          first_or_create_alert_subscription_event(contact, subscription)
        end
      end
    end

  private

    def first_or_create_alert_subscription_event(contact, subscription)
      if contact.email_address?
        AlertSubscriptionEvent.where(contact: contact, alert: @alert, alert_subscription: subscription, communication_type: 'email').first_or_create!
      end

      if contact.mobile_phone_number?
        AlertSubscriptionEvent.where(contact: contact, alert: @alert, alert_subscription: subscription, communication_type: 'sms').first_or_create!
      end
    end

    def any_subscriptions?(school, alert_type)
      subscriptions(school, alert_type).any?
    end

    def subscriptions(school, alert_type)
      school.alert_subscriptions.where(alert_type: alert_type)
    end
  end
end
