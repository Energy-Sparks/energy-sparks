namespace :after_party do
  desc 'Deployment task: add_alert_types_for_targeting_and_tracking'
  task add_alert_types_for_targeting_and_tracking: :environment do
    puts "Running deploy task 'add_alert_types_for_targeting_and_tracking'"

    # Put your task implementation HERE.
    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      title: "Alert Electricity Target Annual",
      class_name: 'AlertElectricityTargetAnnual',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      title: "Alert Gas Target Annual",
      class_name: 'AlertGasTargetAnnual',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      title: "Alert Electricity Target 4 Week",
      class_name: 'AlertElectricityTarget4Week',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      title: "Alert Gas Target 4 Week",
      class_name: 'AlertGasTarget4Week',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      title: "Alert Electricity Target 1 Week",
      class_name: 'AlertElectricityTarget1Week',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      title: "Alert Gas Target 1 Week",
      class_name: 'AlertGasTarget1Week',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      title: "Alert Storage Heater Target Annual",
      class_name: 'AlertStorageHeaterTargetAnnual',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      title: "Alert Storage Heater Target 4 Week",
      class_name: 'AlertStorageHeaterTarget4Week',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      title: "Alert Storage Heater Target 1 Week",
      class_name: 'AlertStorageHeaterTarget1Week',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    )

    # Advice
    # AlertGasTargetAnnual or gas_target
    # AlertElectricityTargetAnnual or electric_target


    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

