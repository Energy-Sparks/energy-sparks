namespace :after_party do
  desc 'Deployment task: Heat Saver March 2024 alerts'
  task heat_saver_march2024_config: :environment do
    puts "Running deploy task 'heat_saver_march2024_alerts'"

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Heat Saver March 2024 Electricity Comparison",
      class_name: 'AlertHeatSaver2024ElectricityComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertHeatSaver2024ElectricityComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Heat Saver March 2024 Gas Comparison",
      class_name: 'AlertHeatSaver2024GasComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertHeatSaver2024GasComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      sub_category: :storage_heaters,
      title: "Heat Saver March 2024 Storage heater Comparison",
      class_name: 'AlertHeatSaver2024StorageHeaterComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertHeatSaver2024StorageHeaterComparison')

    Comparison::Report.create!(
      key: :heat_saver_march_2024,
      title: 'Heat Saver March 2024',
      public: false
    ) unless Comparison::Report.find_by_id(:heat_saver_march_2024)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
