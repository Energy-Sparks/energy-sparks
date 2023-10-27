namespace :onboarding do
  desc "Send onboarding reminders"
  task reminder_mailer: [:environment] do
    if ENV['ENVIRONMENT_IDENTIFIER'] == "production"
      Onboarding::ReminderMailer.deliver_due
    else
      puts "#{Time.zone.now} Only sending onboarding reminders on the production server"
    end
  end
end
