namespace :after_party do
  desc 'Deployment task: add_newsletters_and_training_features'
  task add_newsletters_and_training_features: :environment do
    puts "Running deploy task 'add_newsletters_and_training_features'"

    Flipper.add(:new_newsletters_page)
    Flipper.add(:new_training_page)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
