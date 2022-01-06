namespace :after_party do
  desc 'Deployment task: Create alerts for gas/storage heater during holidays'
  task holiday_heating_water_alerts: :environment do
    puts "Running deploy task 'holiday_heating_water_alerts'"

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Alert Gas Heating/Hot Water On during holidays",
      class_name: 'AlertGasHeatingHotWaterOnDuringHoliday',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertGasHeatingHotWaterOnDuringHoliday')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :storage_heater,
      sub_category: :storage_heaters,
      title: "Alert Storage Heater On during holidays",
      class_name: 'AlertStorageHeaterHeatingOnDuringHoliday',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertStorageHeaterHeatingOnDuringHoliday')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
