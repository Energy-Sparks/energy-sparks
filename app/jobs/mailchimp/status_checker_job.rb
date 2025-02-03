module Mailchimp
  class StatusCheckerJob < ApplicationJob
    def perform
      audience_manager = Mailchimp::AudienceManager.new

      audience_manager.process_list_members.each do |member|
        user = User.find_by_email(member.email_address.downcase)
        # API uses different code to audience export and public docs
        status = member.status == 'transactional' ? :nonsubscribed : member.status.to_sym
        user.update(mailchimp_status: status) if user
      end
    end
  end
end
