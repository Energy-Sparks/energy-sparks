namespace :after_party do
  desc 'Deployment task: update_carbon_data'
  task update_carbon_data: :environment do
    puts "Running deploy task 'update_carbon_data'"

    # Put your task implementation HERE.
    rake_process_carbon_feed(Date.parse('2019-05-1'), Date.yesterday)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
