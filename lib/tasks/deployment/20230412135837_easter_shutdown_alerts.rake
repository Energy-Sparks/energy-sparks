namespace :after_party do
  desc 'Deployment task: easter_shutdown_alerts'
  task easter_shutdown_alerts: :environment do
    puts "Running deploy task 'easter_shutdown_alerts'"

    unless AlertType.find_by(class_name: 'AlertEaster2023ShutdownElectricityComparison')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :electricity,
        sub_category: :electricity_use,
        title: 'Easter shutdown 2023 (electricity)',
        class_name: 'AlertEaster2023ShutdownElectricityComparison',
        source: :analytics,
        has_ratings: true,
        benchmark: true
      )
    end

    unless AlertType.find_by(class_name: 'AlertEaster2023ShutdownGasComparison')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :gas,
        sub_category: :heating,
        title: 'Easter shutdown 2023 (gas)',
        class_name: 'AlertEaster2023ShutdownGasComparison',
        source: :analytics,
        has_ratings: true,
        benchmark: true
      )
    end

    unless AlertType.find_by(class_name: 'AlertEaster2023ShutdownStorageHeaterComparison')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :storage_heater,
        sub_category: :storage_heaters,
        title: 'Easter shutdown 2023  (storage heater)',
        class_name: 'AlertEaster2023ShutdownStorageHeaterComparison',
        source: :analytics,
        has_ratings: true,
        benchmark: true
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
