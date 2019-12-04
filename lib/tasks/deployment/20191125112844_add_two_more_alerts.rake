namespace :after_party do
  desc 'Deployment task: add_two_more_alerts'
  task add_two_more_alerts: :environment do
    puts "Running deploy task 'add_two_more_alerts'"

    # Put your task implementation HERE.
    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      title: "Optimum start time analysis",
      class_name: 'AlertOptimumStartAnalysis',
      source: :analytics,
      benchmark: true
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      title: "Summer holiday refrigeration analysis",
      class_name: 'AlertSummerHolidayRefridgerationAnalysis',
      source: :analytics,
      benchmark: true
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
