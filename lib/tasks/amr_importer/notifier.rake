namespace :amr_importer do
  desc "Send daily notification email of imports"
  task send_daily_notification_email: :environment do
    ImportNotifier.new(description: 'daily imports').notify(from: 24.hours.ago, to: Time.zone.now)
  end
end
