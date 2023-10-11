namespace :after_party do
  desc 'Deployment task: set_park_and_stride'
  task set_park_and_stride: :environment do
    puts "Running deploy task 'set_park_and_stride'"

    TransportType.where('image = ? OR name = ?', '🚶🚘', 'Park and Stride').update_all(park_and_stride: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
