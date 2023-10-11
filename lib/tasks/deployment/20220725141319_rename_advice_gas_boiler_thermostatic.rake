namespace :after_party do
  desc 'Deployment task: rename_advice_gas_boiler_thermostatic'
  task rename_advice_gas_boiler_thermostatic: :environment do
    puts "Running deploy task 'rename_advice_gas_boiler_thermostatic'"

    alert_type = AlertType.find_by(class_name: 'AdviceGasBoilerThermostatic')
    alert_type.update(class_name: 'AdviceGasThermostaticControl')
    alert_type.save!

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
