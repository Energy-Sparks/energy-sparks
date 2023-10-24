namespace :after_party do
  desc 'Deployment task: new_comparison_benchmarks'
  task new_comparison_benchmarks: :environment do
    puts "Running deploy task 'new_comparison_benchmarks'"

    #Creates new benchmarks added in Analytics 2.3.7
    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Comparison between Autumn Terms 2021-2022 (electricity)",
      class_name: 'AlertAutumnTerm20212022ElectricityComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertAutumnTerm20212022ElectricityComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Comparison between Autumn Terms 2021-2022 (gas)",
      class_name: 'AlertAutumnTerm20212022GasComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertAutumnTerm20212022GasComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :storage_heaters,
      title: "Comparison between Autumn Terms 2021-2022 (storage heaters)",
      class_name: 'AlertAutumnTerm20212022StorageHeaterComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertAutumnTerm20212022StorageHeaterComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Comparison between November 2021-2022 (electricity)",
      class_name: 'AlertSeptNov20212022ElectricityComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertSeptNov20212022ElectricityComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Comparison between November 2021-2022 (gas)",
      class_name: 'AlertSeptNov20212022GasComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertSeptNov20212022GasComparison')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :storage_heaters,
      title: "Comparison between November 2021-2022 (storage heaters)",
      class_name: 'AlertSeptNov20212022StorageHeaterComparison',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertSeptNov20212022StorageHeaterComparison')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
