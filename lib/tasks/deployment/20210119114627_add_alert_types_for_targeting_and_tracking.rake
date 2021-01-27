namespace :after_party do
  desc 'Deployment task: add_alert_types_for_targeting_and_tracking'
  task add_alert_types_for_targeting_and_tracking: :environment do
    puts "Running deploy task 'add_alert_types_for_targeting_and_tracking'"

    # Put your task implementation HERE.
    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Alert Electricity Target Annual",
      class_name: 'AlertElectricityTargetAnnual',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertElectricityTargetAnnual')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Alert Gas Target Annual",
      class_name: 'AlertGasTargetAnnual',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertGasTargetAnnual')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Alert Electricity Target 4 Week",
      class_name: 'AlertElectricityTarget4Week',
      source: :analytics,
      has_ratings: true,
      benchmark: false
    ) unless AlertType.find_by_class_name('AlertElectricityTarget4Week')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Alert Gas Target 4 Week",
      class_name: 'AlertGasTarget4Week',
      source: :analytics,
      has_ratings: true,
      benchmark: false
    ) unless AlertType.find_by_class_name('AlertGasTarget4Week')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Alert Electricity Target 1 Week",
      class_name: 'AlertElectricityTarget1Week',
      source: :analytics,
      has_ratings: true,
      benchmark: false
    ) unless AlertType.find_by_class_name('AlertElectricityTarget1Week')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Alert Gas Target 1 Week",
      class_name: 'AlertGasTarget1Week',
      source: :analytics,
      has_ratings: true,
      benchmark: false
    ) unless AlertType.find_by_class_name('AlertGasTarget1Week')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      sub_category: :storage_heaters,
      title: "Alert Storage Heater Target Annual",
      class_name: 'AlertStorageHeaterTargetAnnual',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertStorageHeaterTargetAnnual')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      sub_category: :storage_heaters,
      title: "Alert Storage Heater Target 4 Week",
      class_name: 'AlertStorageHeaterTarget4Week',
      source: :analytics,
      has_ratings: true,
      benchmark: false
    ) unless AlertType.find_by_class_name('AlertStorageHeaterTarget4Week')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      sub_category: :storage_heaters,
      title: "Alert Storage Heater Target 1 Week",
      class_name: 'AlertStorageHeaterTarget1Week',
      source: :analytics,
      has_ratings: true,
      benchmark: false
    ) unless AlertType.find_by_class_name('AlertStorageHeaterTarget1Week')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Advice Targets Electricity",
      class_name: 'AdviceTargetsElectricity',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    ) unless AlertType.find_by_class_name('AdviceTargetsElectricity')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Advice Targets Gas",
      class_name: 'AdviceTargetsGas',
      source: :analysis,
      has_ratings: true,
      benchmark: false
    ) unless AlertType.find_by_class_name('AdviceTargetsGas')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
