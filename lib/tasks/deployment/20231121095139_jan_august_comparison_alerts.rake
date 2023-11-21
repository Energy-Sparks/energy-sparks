namespace :after_party do
  desc 'Deployment task: jan_august_comparison_alerts'
  task jan_august_comparison_alerts: :environment do
    puts "Running deploy task 'jan_august_comparison_alerts'"

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Jan-August 2022-2023 Electricity Comparison",
      class_name: 'AlertJanAug20222023ElectricityComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertJanAug20222023ElectricityComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Jan-August 2022-2023 Gas Comparison",
      class_name: 'AlertJanAug20222023GasComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertJanAug20222023GasComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      sub_category: :storage_heaters,
      title: "Jan-August 2022-2023 Storage heater Comparison",
      class_name: 'AlertJanAug20222023StorageHeaterComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertJanAug20222023StorageHeaterComparison')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
