namespace :after_party do
  desc 'Deployment task: deprecate_old_alerts'
  task deprecate_old_alerts: :environment do
    puts "Running deploy task 'deprecate_old_alerts'"

    puts "Total alerts #{Alert.count}"

    # Put your task implementation HERE.
    AlertType.where(class_name: 'AlertChangeInDailyGasShortTerm').delete_all
    AlertType.where(class_name: 'AlertChangeInDailyElectricityShortTerm').delete_all

    puts "Total alerts #{Alert.count}"

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end