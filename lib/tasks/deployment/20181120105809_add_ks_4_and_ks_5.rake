namespace :after_party do
  desc 'Deployment task: add_ks_4_and_ks_5'
  task add_ks_4_and_ks_5: :environment do
    puts "Running deploy task 'add_ks_4_and_ks_5'"

    # Put your task implementation HERE.
    KeyStage.where(name: 'KS4').first_or_create
    KeyStage.where(name: 'KS5').first_or_create

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20181120105809'
  end
end
