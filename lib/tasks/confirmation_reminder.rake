# frozen_string_literal: true

task confirmation_reminder: :environment do
  if ENV['SEND_AUTOMATED_EMAILS'] == 'true'
    ConfirmationReminder.send
  else
    puts "#{Time.zone.now} Only sending confirmation reminders on the production server"
  end
end
