module Mailchimp
  class StatusCheckerJob < ApplicationJob
    def perform
      audience_manager = Mailchimp::AudienceManager.new

      User.where.not(confirmed_at: nil).where.not(role: :pupil).find_each do |user|
        begin
          contact = audience_manager.get_contact(user.email)
          user.update!(mailchimp_status: contact.status.to_sym) if contact
        rescue => e
          EnergySparks::Log.exception(e, job: :mailchimp_user_status)
          Rollbar.log(e, :mailchimp_user_status, user: user)
        end
      end
    end
  end
end
