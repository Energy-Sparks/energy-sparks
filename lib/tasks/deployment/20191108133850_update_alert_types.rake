namespace :after_party do
  desc 'Deployment task: update_alert_types'
  task update_alert_types: :environment do
    puts "Running deploy task 'update_alert_types'"

    # Put your task implementation HERE.
    AlertType.find_by(class_name: 'AlertElectricityPeakKWVersusBenchmark').update(fuel_type: :electricity)
    AlertType.find_by(class_name: 'AdviceStorageHeaters').update(fuel_type: :storage_heater)
    AlertType.find_by(class_name: 'AdviceSolarPV').update(fuel_type: :solar_pv)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end