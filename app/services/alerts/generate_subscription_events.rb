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
        @school.contacts.each do |contact|
          first_or_create_alert_subscription_event(contact, content, email_active: email_active, sms_active: sms_active)
        end
      end
    end

  private

    def first_or_create_alert_subscription_event(contact, content_version, email_active: true, sms_active: true)
      if email_active && contact.email_address?
        AlertSubscriptionEvent.create_with(content_version: content_version).find_or_create_by!(contact: contact, alert: @alert, communication_type: 'email')
      end

      if sms_active && contact.mobile_phone_number?
        AlertSubscriptionEvent.create_with(content_version: content_version).find_or_create_by!(contact: contact, alert: @alert, communication_type: 'sms')
      end
    end
  end
end
