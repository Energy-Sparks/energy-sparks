namespace :after_party do
  desc 'Deployment task: add_refrigeration_alert'
  task add_refrigeration_alert: :environment do
    puts "Running deploy task 'add_refrigeration_alert'"

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Impact of turning fridges and freezers off over the summer holidays",
      class_name: 'AlertSummerHolidayRefrigerationAnalysis',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertSummerHolidayRefrigerationAnalysis')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
