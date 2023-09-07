namespace :after_party do
  desc 'Deployment task: set_all_meter_half_hourly_values_to_false'
  task set_all_meter_half_hourly_values_to_false: :environment do
    puts "Running deploy task 'set_all_meter_half_hourly_values_to_false'"

    Meter.update_all(half_hourly: false)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end