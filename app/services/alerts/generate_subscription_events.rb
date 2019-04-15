module Alerts
  class GenerateSubscriptionEvents
    def initialize(school, alert)
      @school = school
      @alert = alert
    end

    def perform
      FetchContent.new(@alert).content_versions.each do |content|
        email_active = content.alert_type_rating.email_active
        sms_active = content.alert_type_rating.sms_active
        subscriptions(@school, @alert.alert_type).each do |subscription|
          subscription.contacts.each do |contact|
            first_or_create_alert_subscription_event(contact, subscription, content, email_active: email_active, sms_active: sms_active)
          end
        end
      end
    end

  private

    def first_or_create_alert_subscription_event(contact, subscription, content_version, email_active: true, sms_active: true)
      if email_active && contact.email_address?
        AlertSubscriptionEvent.create_with(content_version: content_version).find_or_create_by!(contact: contact, alert: @alert, alert_subscription: subscription, communication_type: 'email')
      end

      if sms_active && contact.mobile_phone_number?
        AlertSubscriptionEvent.create_with(content_version: content_version).find_or_create_by!(contact: contact, alert: @alert, alert_subscription: subscription, communication_type: 'sms')
      end
    end

    def subscriptions(school, alert_type)
      school.alert_subscriptions.where(alert_type: alert_type)
    end
  end
end
