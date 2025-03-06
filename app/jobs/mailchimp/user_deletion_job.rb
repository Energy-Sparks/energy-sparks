module Mailchimp
  # Triggered when we delete a user to reset the users contact details in Mailchimp so that they
  # are switched to being an "Organic" subscriber.
  class UserDeletionJob < BaseJob
    def perform(email_address:, name:, school:)
      return unless can_run?

      contact = Mailchimp::Contact.from_params({ email_address:, name:, school:, interests: {} })
      audience_manager = AudienceManager.new
      mailchimp_member = audience_manager.update_contact(contact)
      audience_manager.remove_tags_from_contact(email_address, tags_to_remove(mailchimp_member))
    rescue => e
      EnergySparks::Log.exception(e, job: :user_deletion)
    end

    private

    def tags_to_remove(mailchimp_member)
      return [] unless mailchimp_member&.tags
      # Returned as array of hashes with id and name, extract the name
      tags_in_mailchimp = mailchimp_member.tags.map { |t| t['name'] }
      # Reject anything except the automatically added tags
      tags_in_mailchimp.reject! {|t| !(t.include?('-') || t.start_with?('FSM')) }
      tags_in_mailchimp
    end
  end
end
