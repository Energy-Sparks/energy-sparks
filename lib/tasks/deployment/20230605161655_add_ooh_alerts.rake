namespace :after_party do
  desc 'Deployment task: add_ooh_alerts'
  task add_ooh_alerts: :environment do
    puts "Running deploy task 'add_ooh_alerts'"

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Electricity out of hours, previous year",
      class_name: 'AlertOutOfHoursElectricityUsagePreviousYear',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertOutOfHoursElectricityUsagePreviousYear')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Gas out of hours, previous year",
      class_name: 'AlertOutOfHoursGasUsagePreviousYear',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertOutOfHoursGasUsagePreviousYear')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      sub_category: :storage_heaters,
      title: "Storage heater out of hours, previous year",
      class_name: 'AlertOutOfHoursStorageHeaterUsagePreviousYear',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertOutOfHoursStorageHeaterUsagePreviousYear')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
