namespace :after_party do
  desc 'Deployment task: flipper_meter_collection_cache_delete_on_invalidate'
  task flipper_meter_collection_cache_delete_on_invalidate: :environment do
    puts "Running deploy task 'flipper_meter_collection_cache_delete_on_invalidate'"

    Flipper.add(:meter_collection_cache_delete_on_invalidate)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
