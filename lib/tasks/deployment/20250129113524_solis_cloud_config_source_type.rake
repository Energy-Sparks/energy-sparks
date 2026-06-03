namespace :after_party do
  desc 'Deployment task: solis_cloud_config_source_type'
  task solis_cloud_config_source_type: :environment do
    puts "Running deploy task 'solis_cloud_config_source_type'"

    AmrDataFeedConfig.find_by(identifier: 'solis-cloud').update!(source_type: :api)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
