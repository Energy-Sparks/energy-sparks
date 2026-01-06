namespace :after_party do
  desc 'Deployment task: remove_todos_features'
  task remove_todos_features: :environment do
    puts "Running deploy task 'remove_todos_features'"

    Flipper.remove(:todos)
    Flipper.remove(:todos_parallel)
    Flipper.remove(:todos_old)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
