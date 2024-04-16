namespace :after_party do
  desc 'Deployment task: configurable_period_alerts'
  task configurable_period_alerts: :environment do
    puts "Running deploy task 'configurable_period_alerts'"

    unless AlertType.find_by(class_name: 'AlertConfigurablePeriodElectricityComparison')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :electricity,
        sub_category: :electricity_use,
        title: 'Configurable Electricity Comparison',
        class_name: 'AlertConfigurablePeriodElectricityComparison',
        source: :analytics,
        has_ratings: true,
        benchmark: true
      )
    end

    unless AlertType.find_by(class_name: 'AlertConfigurablePeriodGasComparison')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :gas,
        sub_category: :heating,
        title: 'Configurable Gas Comparison',
        class_name: 'AlertConfigurablePeriodGasComparison',
        source: :analytics,
        has_ratings: true,
        benchmark: true
      )
    end

    unless AlertType.find_by(class_name: 'AlertConfigurablePeriodStorageHeaterComparison')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :storage_heater,
        sub_category: :storage_heaters,
        title: 'Configurable Storage heater Comparison',
        class_name: 'AlertConfigurablePeriodStorageHeaterComparison',
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
