namespace :after_party do
  desc 'Deployment task: onboarding_mailer2025_flipper'
  task onboarding_mailer2025_flipper: :environment do
    puts "Running deploy task 'onboarding_mailer2025_flipper'"

    Flipper.add(:onboarding_mailer_2025)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
