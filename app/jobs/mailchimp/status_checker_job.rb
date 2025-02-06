module Mailchimp
  class StatusCheckerJob < ApplicationJob
    def perform
      audience_manager = Mailchimp::AudienceManager.new

      updated_users = []
      audience_manager.process_list_members.each do |member|
        user = User.find_by_email(member.email_address.downcase)
        if user
          user.update(mailchimp_status: Mailchimp::AudienceManager.status(member.status))
          updated_users << user
        end
      end

      # Any other user with a status that was not just updated must have its status removed
      # Could happen if a user is deleted from Mailchimp, or their email address has changed.
      User.where.not(id: updated_users).where.not(mailchimp_status: nil).update_all(mailchimp_status: nil)
    end
  end
end
