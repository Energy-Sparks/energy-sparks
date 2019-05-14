module Alerts
  class GenerateSubscriptionEvents
    def initialize(school)
      @school = school
    end

    def perform(frequency: [], content_generation_run: nil)
      ActiveRecord::Base.transaction do
        content_generation_run ||= ContentGenerationRun.create!(school: @school)
        @school.alerts.joins(:alert_type).where(alert_types: { frequency: frequency }).latest.each do |alert|
          FetchContent.new(alert).content_versions.each do |content|
            email_active = content.alert_type_rating.email_active
            sms_active = content.alert_type_rating.sms_active
            @school.contacts.each do |contact|
              first_or_create_alert_subscription_event(content_generation_run, contact, content, alert, email_active: email_active, sms_active: sms_active)
            end
          end
        end
      end
    end

  private

    def first_or_create_alert_subscription_event(content_generation_run, contact, content_version, alert, email_active: true, sms_active: true)
      find_out_more = content_generation_run.find_out_mores.where(content_version: content_version).first
      if email_active && contact.email_address?
        AlertSubscriptionEvent.create_with(
          content_version: content_version,
          content_generation_run: content_generation_run,
          find_out_more: find_out_more
        ).find_or_create_by!(
          contact: contact, alert: alert, communication_type: 'email'
        )
      end

      if sms_active && contact.mobile_phone_number?
        AlertSubscriptionEvent.create_with(
          content_version: content_version,
          content_generation_run: content_generation_run,
          find_out_more: find_out_more
        ).find_or_create_by!(
          contact: contact, alert: alert, communication_type: 'sms'
        )
      end
    end
  end
end
