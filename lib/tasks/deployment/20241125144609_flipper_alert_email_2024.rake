namespace :after_party do
  desc 'Deployment task: flipper_alert_email_2024'
  task flipper_alert_email_2024: :environment do
    puts "Running deploy task 'flipper_alert_email_2024'"

    Flipper.add(:alert_email_2024)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
