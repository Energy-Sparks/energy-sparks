namespace :after_party do
  desc 'Deployment task: metering_agent_charge'
  task metering_agent_charge: :environment do
    puts "Running deploy task 'metering_agent_charge'"

    EnergyTariffCharge.where(charge_type: :nhh_metering_agent_charge, units: :kwh).update_all(units: :day)
    EnergyTariffCharge.where(charge_type: :nhh_automatic_meter_reading_charge, units: :kwh).update_all(units: :day)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
