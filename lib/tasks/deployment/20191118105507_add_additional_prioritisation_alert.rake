namespace :after_party do
  desc 'Deployment task: add_additional_prioritisation_alert'
  task add_additional_prioritisation_alert: :environment do
    puts "Running deploy task 'add_additional_prioritisation_alert'"

    # Put your task implementation HERE.
    AlertType.create!(
      frequency: :weekly,
      fuel_type: nil,
      title: "Additional Prioritisation Data for benchmarking",
      class_name: 'AlertAdditionalPrioritisationData',
      source: :analytics,
      background: true,
      has_ratings: false
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
