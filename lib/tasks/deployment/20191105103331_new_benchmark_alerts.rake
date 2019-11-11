namespace :after_party do
  desc 'Deployment task: new_benchmark_alerts'
  task new_benchmark_alerts: :environment do
    puts "Running deploy task 'new_benchmark_alerts'"

    # Put your task implementation HERE.
    AlertType.create!(
      frequency: :termly,
      fuel_type: :electricity,
      title: "Solar PV Benefits Estimator",
      class_name: 'AlertSolarPVBenefitEstimator',
      source: :analytics
    )

    AlertType.create!(
      frequency: :termly,
      fuel_type: :storage_heater,
      title: "Storage heater annual versus benchmark",
      class_name: 'AlertStorageHeaterAnnualVersusBenchmark',
      source: :analytics
    )

    AlertType.create!(
      frequency: :termly,
      fuel_type: :storage_heater,
      title: "Storage heater thermostatic",
      class_name: 'AlertStorageHeaterThermostatic',
      source: :analytics
    )

    AlertType.create!(
      frequency: :termly,
      fuel_type: :storage_heater,
      title: "Storage heater out of hours",
      class_name: 'AlertStorageHeaterOutOfHours',
      source: :analytics
    )

    AlertType.create!(
      frequency: :termly,
      fuel_type: :storage_heater,
      title: "Storage heater heating on school days",
      class_name: 'AlertHeatingOnSchoolDaysStorageHeaters',
      source: :analytics
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
