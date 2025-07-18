namespace :after_party do
  desc 'Deployment task: add_new_workshops_page_feature'
  task add_new_workshops_page_feature: :environment do
    puts "Running deploy task 'add_new_workshops_page_feature'"

    Flipper.add(:new_workshops_page)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
