namespace :after_party do
  desc 'Deployment task: add_layer_up_power_down_day_alerts'
  task add_layer_up_power_down_day_alerts: :environment do
    puts "Running deploy task 'add_layer_up_power_down_day_alerts'"

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Layer Up Power Down November 2023 Electricity Comparison",
      class_name: 'AlertLayerUpPowerdownNovember2023ElectricityComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertLayerUpPowerdownNovember2023ElectricityComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Layer Up Power Down November 2023 Gas Comparison",
      class_name: 'AlertLayerUpPowerdownNovember2023GasComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertLayerUpPowerdownNovember2023GasComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      sub_category: :storage_heaters,
      title: "Layer Up Power Down November 2023 Storage heater Comparison",
      class_name: 'AlertLayerUpPowerdownNovember2023StorageHeaterComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertLayerUpPowerdownNovember2023StorageHeaterComparison')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
