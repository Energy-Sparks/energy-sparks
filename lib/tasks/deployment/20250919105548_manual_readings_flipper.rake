namespace :after_party do
  desc 'Deployment task: manual_readings_flipper'
  task manual_readings_flipper: :environment do
    puts "Running deploy task 'manual_readings_flipper'"

    Flipper.enable_group(:manual_readings, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
