namespace :after_party do
  desc 'Deployment task: remove_old_error_messages'
  task remove_old_error_messages: :environment do
    puts "Running deploy task 'remove_old_error_messages'"

    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end