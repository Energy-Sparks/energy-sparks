namespace :after_party do
  desc 'Deployment task: update alert impending holiday alert types'
  task update_alert_impending_holiday_alert_types: :environment do
    puts "Running deploy task 'update_alert_impending_holiday_alert_types'"

    # Put your task implementation HERE.
    alert_imending_holiday = AlertType.find_by(class_name: 'AlertImpendingHoliday')
    alert_imending_holiday_benchmark = alert_imending_holiday.dup
    alert_imending_holiday_benchmark.class_name = 'AlertImpendingHolidayBenchmark'
    alert_imending_holiday_benchmark.benchmark = true
    alert_imending_holiday_benchmark.save!
    alert_imending_holiday.update(benchmark: false)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end