module Alerts
  class GenerateSubscriptionEvents
    def initialize(school, alert)
      @school = school
      @alert = alert
    end

    def perform
      rating = @alert.raw_rating
      return if rating.blank?
      alert_type_ratings = AlertTypeRating.for_rating(rating.to_f.round(1)).where(alert_type: @alert.alert_type)
      alert_type_ratings.each do |alert_type_rating|
        content = alert_type_rating.current_content
        next if content.nil?
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

    def any_subscriptions?(school, alert_type)
      subscriptions(school, alert_type).any?
    end

    def subscriptions(school, alert_type)
      school.alert_subscriptions.where(alert_type: alert_type)
    end
  end
end
