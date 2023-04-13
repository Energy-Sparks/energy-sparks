namespace :after_party do
  desc 'Deployment task: remove_readings_with_all_dashes'
  task remove_readings_with_all_dashes: :environment do
    puts "Running deploy task 'remove_readings_with_all_dashes'"

    #Remove all readings where the contents are only dashes.
    AmrDataFeedReading.where(readings: Array.new(48, "-")).destroy_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
