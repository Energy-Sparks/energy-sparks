namespace :after_party do
  desc 'Deployment task: remove_sandbox_meters'
  task remove_sandbox_meters: :environment do
    puts "Running deploy task 'remove_sandbox_meters'"

    # Remove all of the old v1 n3rgy api sandbox meters
    Meter.where(dcc_meter: true, sandbox: true).each do |meter|
      manager = MeterManagement.new(meter)
      manager.deactivate_meter!
      manager.remove_data!
      manager.delete_meter!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
