module Alerts
  class GenerateEmailNotifications
    def initialize(subscription_generation_run:)
      @subscription_generation_run = subscription_generation_run
    end

    def perform
      events = @subscription_generation_run.alert_subscription_events.where(status: :pending, communication_type: :email).by_priority
      events.group_by(&:contact).each do |contact, contact_events|
        email = Email.create!(contact: contact)
        AlertMailer.with(email_address: contact.email_address, events: contact_events, school: contact.school).alert_email.deliver_now
        contact_events.each {|event| event.update!(status: :sent, email: email) }
        email.update(sent_at: Time.now.utc)
      end
    end
  end
end
