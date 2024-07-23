namespace :after_party do
  desc 'Deployment task: run_dcc_checker'
  task run_dcc_checker: :environment do
    puts "Running deploy task 'run_dcc_checker'"

    # Put your task implementation HERE.
    Rake::Task['meters:check_for_dcc'].invoke

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
