module Mailchimp
  class AudienceUpdater
    def perform
      audience_manager = Mailchimp::AudienceManager.new
      User.mailchimp_update_required.mailchimp_roles.find_each do |user|
        begin
          contact = Mailchimp::Contact.from_user(user)

          # Use update contact here, not subscribe_or_update
          mailchimp_member = audience_manager.update_contact(contact)

          tags_to_remove = tags_to_remove(mailchimp_member, contact)
          audience_manager.remove_tags_from_contact(contact.email_address, tags_to_remove) if tags_to_remove.any?

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

    private

    # Identify which tags are now in Mailchimp that have been added by the
    # application and return a list of those that should be removed
    #
    # Ignore anything that isn't a school slug or a FSM* tag
    #
    # Remove any that we just added as part of the update
    #
    def tags_to_remove(mailchimp_member, contact)
      return [] unless mailchimp_member&.tags
      # Returned as array of hashes with id and name, extract the name
      tags_in_mailchimp = mailchimp_member.tags.map { |t| t['name'] }
      # Reject anything except the automatically added tags
      tags_in_mailchimp.reject! {|t| !(t.include?('-') || t.start_with?('FSM')) }
      # Return those we haven't just added
      tags_in_mailchimp - contact.tags
    end
  end
end
