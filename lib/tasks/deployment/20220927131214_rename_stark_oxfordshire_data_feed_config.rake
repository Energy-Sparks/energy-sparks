namespace :after_party do
  desc 'Deployment task: rename_stark_oxfordshire_data_feed_config'
  task rename_stark_oxfordshire_data_feed_config: :environment do
    puts "Running deploy task 'rename_stark_oxfordshire_data_feed_config'"

    amr_data_feed_config = AmrDataFeedConfig.find_by(identifier: 'stark')
    amr_data_feed_config.update!(description: 'Stark (daily)')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
