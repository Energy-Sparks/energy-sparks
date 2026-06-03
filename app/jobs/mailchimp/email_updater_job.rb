module Mailchimp
  class EmailUpdaterJob < BaseJob
    def perform(user:, original_email:)
      return unless can_run?

      contact = Mailchimp::Contact.from_user(user)
      mailchimp_member = Mailchimp::AudienceManager.new.update_contact(contact, original_email)
      # Update status as well seeing as its returned in the response
      user.update(
        mailchimp_updated_at: Time.zone.now,
        mailchimp_status: Mailchimp::AudienceManager.status(mailchimp_member.status)
      )
    rescue => e
      EnergySparks::Log.exception(e, job: :audience_updater)
    end
  end
end
