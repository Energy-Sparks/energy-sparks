namespace :after_party do
  desc 'Deployment task: first_adult_analysis_alert_type'
  task first_adult_analysis_alert_type: :environment do
    puts "Running deploy task 'first_adult_analysis_alert_type'"

    AlertType.create!(
      frequency: :weekly,
      title: "Gas: out of hours",
      class_name: 'AdviceGasOutHours',
      source: 'analysis',
      sub_category: :heating,
      fuel_type: :gas
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
