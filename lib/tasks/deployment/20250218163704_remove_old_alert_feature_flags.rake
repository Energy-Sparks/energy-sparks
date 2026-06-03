namespace :after_party do
  desc 'Deployment task: remove_old_alert_feature_flags'
  task remove_old_alert_feature_flags: :environment do
    puts "Running deploy task 'remove_old_alert_feature_flags'"

    Flipper.remove(:batch_send_weekly_alerts)
    Flipper.remove(:alert_email_2024)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
