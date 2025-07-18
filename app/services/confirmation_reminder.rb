# frozen_string_literal: true

# Send confirmation reminders to specific types of user accounts, ignoring deleted or archived schools
#
# Do not chase old accounts.
module ConfirmationReminder
  CONFIRMABLE_ROLES = [:staff, :school_admin, :group_admin].freeze

  def self.send
    now = Time.current
    User.where(role: CONFIRMABLE_ROLES) # restrict to specific set of roles
        .where('created_at >= ?', 31.days.ago) # ignore old accounts
        .where('confirmed_at IS NULL AND confirmation_sent_at IS NOT NULL').find_each do |user|
      next if user.school && user.school.not_active?
      if should_send_reminder(now, user, 30.days)
        EnergySparksDeviseMailer.confirmation_instructions_final_reminder(user, user.confirmation_token).deliver_now
        user.update!(confirmation_sent_at: now)
      elsif should_send_reminder(now, user, 7.days)
        EnergySparksDeviseMailer.confirmation_instructions_first_reminder(user, user.confirmation_token).deliver_now
        user.update!(confirmation_sent_at: now)
      end
    end
  end

  def self.should_send_reminder(now, user, days)
    time_since_creation = now - user.created_at
    time_between_creation_and_confirmation = user.confirmation_sent_at - user.created_at
    time_since_creation >= days && time_between_creation_and_confirmation < days
  end
end
