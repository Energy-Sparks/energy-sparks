module Mailchimp
  class StatusCheckerJob < ApplicationJob
    def perform
      audience_manager = Mailchimp::AudienceManager.new

      audience_manager.process_list_members.each do |member|
        user = User.find_by_email(member.email_address.downcase)
        user.update(mailchimp_status: Mailchimp::AudienceManager.status(member.status)) if user
      end
    end
  end
end
