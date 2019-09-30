namespace :after_party do
  desc 'Deployment task: add_impending_holiday_alert'
  task add_impending_holiday_alert: :environment do
    puts "Running deploy task 'add_impending_holiday_alert'"

    AlertType.create(
      frequency: :termly,
      title: "Impending holiday",
      description: "Impending holiday",
      class_name: 'AlertImpendingHoliday',
      source: 'analytics'
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
