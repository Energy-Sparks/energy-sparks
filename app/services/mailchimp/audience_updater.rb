module Mailchimp
  class AudienceUpdater
    def perform
      audience_manager = Mailchimp::AudienceManager.new
      User.mailchimp_update_required.mailchimp_roles do |user|
        begin
          # Don't specify tags here as update will only add them, not remove
          # FIXME what about interests?
          contact = Mailchimp::Contact.from_user(user)

          # FIXME feature flag?
          # Use update contact here, not subscribe_or_update as we're not adding all users initially
          mailchimp_member = audience_manager.update_contact(contact)

          # TODO check whether we need to update the tags by checking those in the response versus user
          # could just add all tags, then remove any that no longer apply??
          # TODO update tags, if required

          # Update status as well seeing as its returned in the response
          user.update(
            mailchimp_updated_at: Time.zone.now,
            mailchimp_status: Mailchimp::AudienceManager.status(mailchimp_member.status)
          )
        rescue => e
          EnergySparks::Log.exception(e)
        end
      end
    end
  end
end
