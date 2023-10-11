module Alerts
  class GenerateEmailNotifications
    def initialize(subscription_generation_run:)
      @subscription_generation_run = subscription_generation_run
    end

    def perform
      events = @subscription_generation_run.alert_subscription_events.where(status: :pending, communication_type: :email).by_priority
      events.group_by(&:contact).each do |contact, contact_events|
        email = Email.create!(contact: contact)
        target_prompt = include_target_prompt_in_email?(contact.school)
        AlertMailer.with_contact_locale(contact: contact, events: contact_events, target_prompt: target_prompt) { |mailer| mailer.alert_email.deliver_now }
        contact_events.each { |event| event.update!(status: :sent, email: email) }
        email.update(sent_at: Time.now.utc)
      end
    end

    private

    def include_target_prompt_in_email?(school)
      Targets::SchoolTargetService.targets_enabled?(school) && Targets::SchoolTargetService.new(school).enough_data?
    end
  end
end
