module Alerts
  class GenerateEmailNotifications
    def initialize(subscription_generation_run:)
      @subscription_generation_run = subscription_generation_run
    end

    # Can later be refactored to store single email and events rather than per contact
    def perform
      events = @subscription_generation_run.alert_subscription_events.where(status: :pending, communication_type: :email).by_priority
      return unless events.any? # may not have any pending

      target_prompt = include_target_prompt_in_email?(@subscription_generation_run.school)

      by_contact = events.group_by(&:contact)
      # all contacts to bcc to this email
      all_contacts = by_contact.keys
      # content for email, using contact_events for first contact, will be same for all users
      common_events = by_contact.first.last

      # send email(s) one for each of the preferred locales
      AlertMailer.with_user_locales(users: all_contacts, school: @subscription_generation_run.school, events: common_events, target_prompt: target_prompt) do |mailer|
        mailer.alert_email.deliver_now
      end

      # generate an Email and mark all as sent
      by_contact.each do |contact, contact_events|
        email = Email.create!(contact: contact)
        contact_events.each {|event| event.update!(status: :sent, email: email) }
        email.update(sent_at: Time.now.utc)
      end
    end

    private

    def include_target_prompt_in_email?(school)
      return Targets::SchoolTargetService.targets_enabled?(school) && Targets::SchoolTargetService.new(school).enough_data?
    end
  end
end
