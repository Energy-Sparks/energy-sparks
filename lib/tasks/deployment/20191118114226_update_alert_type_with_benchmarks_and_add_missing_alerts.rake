namespace :after_party do
  desc 'Deployment task: update_alert_type_with_benchmarks_and_add_missing_alerts'
  task update_alert_type_with_benchmarks_and_add_missing_alerts: :environment do
    puts "Running deploy task 'update_alert_type_with_benchmarks_and_add_missing_alerts'"

    # Put your task implementation HERE.
    AlertType.create!(
      frequency: :termly,
      fuel_type: :electricity,
      title: "Electricity long term trend",
      class_name: 'AlertElectricityLongTermTrend',
      source: :analytics
    )

    AlertType.create!(
      frequency: :termly,
      fuel_type: nil,
      title: "Annual energy usage versus benchmark",
      class_name: 'AlertEnergyAnnualVersusBenchmark',
      source: :analytics
    )

    AlertType.create!(
      frequency: :termly,
      fuel_type: :gas,
      title: "Gas long term trend",
      class_name: 'AlertGasLongTermTrend',
      source: :analytics
    )

    AlertType.create!(
      frequency: :termly,
      fuel_type: :storage_heater,
      title: "Storage heaters long term trend",
      class_name: 'AlertStorageHeatersLongTermTrend',
      source: :analytics
    )

    AlertAnalysisBase.all_available_alerts.each do |class_name|
      AlertType.where(class_name: class_name).update(benchmark: true)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
