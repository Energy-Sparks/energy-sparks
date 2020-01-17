namespace :after_party do
  desc 'Deployment task: new_missing_data_system_alerts'
  task new_missing_data_system_alerts: :environment do
    puts "Running deploy task 'new_missing_data_system_alerts'"

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      title: "Missing gas data",
      class_name: 'Alerts::System::MissingGasData',
      source: :system,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      title: "Missing electricity data",
      class_name: 'Alerts::System::MissingElectricityData',
      source: :system,
      benchmark: false
    )


    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
