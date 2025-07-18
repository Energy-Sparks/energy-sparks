# frozen_string_literal: true

class DeviseMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    EnergySparksDeviseMailer.confirmation_instructions(user, user.confirmation_token)
  end

  def confirmation_instructions_first_reminder
    EnergySparksDeviseMailer.confirmation_instructions_first_reminder(user, user.confirmation_token)
  end

  def confirmation_instructions_final_reminder
    EnergySparksDeviseMailer.confirmation_instructions_final_reminder(user, user.confirmation_token)
  end

  def email_changed
    EnergySparksDeviseMailer.email_changed(user, user.confirmation_token)
  end

  def password_change
    EnergySparksDeviseMailer.password_change(user, user.reset_password_token)
  end

  def reset_password_instructions
    EnergySparksDeviseMailer.reset_password_instructions(user, user.reset_password_token)
  end

  def unlock_instructions
    EnergySparksDeviseMailer.unlock_instructions(user, user.unlock_token)
  end

  private

  def user
    User.new(name: 'Name', email: 'test@example.com', reset_password_token: 'fake_token',
             school: School.new(name: 'Test School', country: 'wales'))
  end
end
