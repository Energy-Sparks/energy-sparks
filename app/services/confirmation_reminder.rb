# frozen_string_literal: true

module ConfirmationReminder
  def self.send
    now = Time.current
    User.where('confirmed_at IS NULL AND confirmation_sent_at IS NOT NULL').find_each do |user|
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
