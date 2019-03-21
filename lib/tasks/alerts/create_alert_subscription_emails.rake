namespace :alerts do
  desc 'Run alert subscription emails job'
  task create_alert_subscription_emails: [:environment] do
    puts Time.zone.now
    Alerts::GenerateEmailNotifications.new.perform
    puts Time.zone.now
  end
end
