namespace :after_party do
  desc 'Deployment task: remove_wybourn_supplementary'
  task remove_wybourn_supplementary: :environment do
    puts "Running deploy task 'remove_wybourn_supplementary'"

    # Put your task implementation HERE.

    readings_before = AmrDataFeedReading.count

    puts "Total amr data feed readings before: #{readings_before}"

    AmrDataFeedImportLog.where(file_name: 'wybourn-supplementary.csv').delete_all

    readings_after = AmrDataFeedReading.count

    puts "Total amr data feed readings after: #{readings_after}"
    puts "Deleted: #{readings_before - readings_after} days of readings"

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
