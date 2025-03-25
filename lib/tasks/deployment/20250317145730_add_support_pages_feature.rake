namespace :after_party do
  desc 'Deployment task: add_support_pages_feature'
  task add_support_pages_feature: :environment do
    puts "Running deploy task 'add_support_pages_feature'"

    Flipper.add(:support_pages)
    Flipper.enable_group(:support_pages, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
