# frozen_string_literal: true

module Alerts
  class GenerateEmailNotifications
    def initialize(subscription_generation_run:)
      @subscription_generation_run = subscription_generation_run
    end

    # Can later be refactored to store single email and events rather than per contact
    def perform
      events = @subscription_generation_run.alert_subscription_events
                                           .where(status: :pending, communication_type: :email).by_priority
      return unless events.any? # may not have any pending

      by_contact = events.group_by(&:contact)
      send(by_contact)
      record_sent(by_contact)
    end

    private

    def send(by_contact)
      school = @subscription_generation_run.school
      AlertMailer.with_user_locales(users: by_contact.keys,
                                    school:,
                                    # content for email, contact_events for first contact, will be same for all users
                                    events: by_contact.first.last,
                                    target_prompt: include_target_prompt_in_email?(school)) do |mailer|
        mailer.alert_email.deliver_now
      end
    end

    def record_sent(by_contact)
      # generate an Email and mark all as sent
      by_contact.each do |contact, contact_events|
        email = Email.create!(contact: contact)
        contact_events.each { |event| event.update!(status: :sent, email: email) }
        email.update(sent_at: Time.now.utc)
      end
    end

    def include_target_prompt_in_email?(school)
      Targets::SchoolTargetService.targets_enabled?(school) && Targets::SchoolTargetService.new(school).enough_data?
    end
  end
end
