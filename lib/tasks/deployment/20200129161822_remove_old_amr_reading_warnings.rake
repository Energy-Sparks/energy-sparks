namespace :after_party do
  desc 'Deployment task: remove_old_amr_reading_warnings'
  task remove_old_amr_reading_warnings: :environment do
    puts "Running deploy task 'remove_old_amr_reading_warnings'"

    # Put your task implementation HERE.
    AmrReadingWarning.where.not(warning: nil).delete_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
