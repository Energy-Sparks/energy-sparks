namespace :after_party do
  desc 'Deployment task: remove_new_pricing_page_feature'
  task remove_new_pricing_page_feature: :environment do
    puts "Running deploy task 'remove_new_pricing_page_feature'"

    Flipper.remove(:new_pricing_page)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
