namespace :onboarding do
  desc "Send onboarding reminders"
  task reminder_mailer: [:environment] do
    if ENV['SEND_AUTOMATED_EMAILS'] == 'true'
      Onboarding::ReminderMailer.deliver_due
    else
      puts "#{Time.zone.now} Only sending onboarding reminders on the production server"
    end
  end
end
