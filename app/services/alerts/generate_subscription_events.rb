require 'securerandom'

module Alerts
  class GenerateSubscriptionEvents
    def initialize(school, content_generation_run:)
      @school = school
      @content_generation_run = content_generation_run
    end

    def perform(alerts)
      alerts.each do |alert|
        content_and_contacts_for(alert, :email) do |content_version, find_out_more, contact, priority|
          first_or_create_alert_subscription_event(contact, alert, content_version, find_out_more, priority, :email) if contact.email_address?
        end
        content_and_contacts_for(alert, :sms) do |content_version, find_out_more, contact, priority|
          first_or_create_alert_subscription_event(contact, alert, content_version, find_out_more, priority, :sms) if contact.mobile_phone_number?
        end
      end
    end

  private

    def content_and_contacts_for(alert, scope)
      FetchContent.new(alert).content_versions_with_priority(scope: scope).each do |content_version, priority|
        find_out_more = @content_generation_run.find_out_mores.where(content_version: content_version).first
        @school.contacts.each do |contact|
          yield content_version, find_out_more, contact, priority
        end
      end
    end

    def first_or_create_alert_subscription_event(contact, alert, content_version, find_out_more, priority, communication_type)
      if contact.alert_type_rating_unsubscriptions.active(Time.zone.today).where(alert_type_rating: content_version.alert_type_rating).empty?
        AlertSubscriptionEvent.create_with(
          content_version: content_version,
          content_generation_run: @content_generation_run,
          find_out_more: find_out_more,
          unsubscription_uuid: SecureRandom.uuid,
          priority: priority
        ).find_or_create_by!(
          contact: contact, alert: alert, communication_type: communication_type
        )
      end
    end
  end
end
