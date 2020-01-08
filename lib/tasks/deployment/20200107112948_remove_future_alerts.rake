namespace :after_party do
  desc 'Deployment task: remove_future_alerts'
  task remove_future_alerts: :environment do
    puts "Running deploy task 'remove_future_alerts'"

    # Put your task implementation HERE.
    Alert.where('run_on > ?', Date.today).delete_all
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
