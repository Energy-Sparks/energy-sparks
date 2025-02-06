module Mailchimp
  class EmailUpdaterJob < ApplicationJob
    def perform(user:, original_email:)
      contact = Mailchimp::Contact.from_user(user)
      Mailchimp::AudienceManager.update_contact(contact, original_email)
    rescue => e
      EnergySparks::Log.exception(e, job: :audience_updater)
    end
  end
end
