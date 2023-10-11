namespace :after_party do
  desc 'Deployment task: remove_readings_with_all_dashes'
  task remove_readings_with_all_dashes: :environment do
    puts "Running deploy task 'remove_readings_with_all_dashes'"

    # Remove all readings where the contents are only dashes.
    # Should remove around 780-800 records
    AmrDataFeedReading.where(readings: Array.new(48, '-')).destroy_all

    # Remove all readings where there is more than one dash
    #
    # First where clause: find record that have a dash in the readings array
    # this just intersects the readings with an array of containing a single dash
    #
    # Second where clause:
    # uses the array_positions function to find the positions of the "-" in the readings array
    # then calculates the cardinality of that array (which is equal to number of dashes)
    # when limit selection to where cardinality is > 1
    #
    # Should end up removing around 200 records
    AmrDataFeedReading.where('readings && ARRAY[?]', ['-']).where("cardinality(array_positions(readings, '-')) > 1").destroy_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
