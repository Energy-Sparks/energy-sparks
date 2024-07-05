namespace :after_party do
  desc 'Deployment task: add_meter_breakdown_advice_pages'
  task add_meter_breakdown_advice_pages: :environment do
    puts "Running deploy task 'add_meter_breakdown_advice_pages'"

    AdvicePage.create!({
      key: :electricity_meter_breakdown,
      fuel_type: :electricity,
      multiple_meters: true
    }) unless AdvicePage.find_by_key(:electricity_meter_breakdown)

    AdvicePage.create!({
      key: :gas_meter_breakdown,
      fuel_type: :gas,
      multiple_meters: true
    }) unless AdvicePage.find_by_key(:gas_meter_breakdown)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
