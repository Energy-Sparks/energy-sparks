namespace :after_party do
  desc 'Deployment task: update_dcc_meter_meter_sytems'
  task update_dcc_meter_meter_sytems: :environment do
    puts "Running deploy task 'update_dcc_meter_meter_sytems'"

    Meter.dcc.update_all(meter_system: :smets2_smart)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
