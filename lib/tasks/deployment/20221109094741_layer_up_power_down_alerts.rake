namespace :after_party do
  desc 'Deployment task: layer_up_power_down_alerts'
  task layer_up_power_down_alerts: :environment do
    puts "Running deploy task 'layer_up_power_down_alerts'"

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "One-off 11 Nov 2022 Layer up power down event (electricity)",
      class_name: 'AlertLayerUpPowerdown11November2022ElectricityComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertLayerUpPowerdown11November2022ElectricityComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "One-off 11 Nov 2022 Layer up power down event (gas)",
      class_name: 'AlertLayerUpPowerdown11November2022GasComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertLayerUpPowerdown11November2022GasComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      sub_category: :storage_heaters,
      title: "One-off 11 Nov 2022 Layer up power down event (storage heater)",
      class_name: 'AlertLayerUpPowerdown11November2022StorageHeaterComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertLayerUpPowerdown11November2022StorageHeaterComparison')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
