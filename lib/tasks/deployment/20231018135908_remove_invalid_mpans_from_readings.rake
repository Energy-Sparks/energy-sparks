namespace :after_party do
  desc 'Deployment task: remove_invalid_mpans_from_readings'
  task remove_invalid_mpans_from_readings: :environment do
    puts "Running deploy task 'remove_invalid_mpans_from_readings'"

    #Remove readings that have been manually uploads with mpans that have been
    #reformatted by Excel, e.g. to "22E+13"
    AmrDataFeedReading.where("mpan_mprn like ?", "%+%").delete_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
