namespace :after_party do
  desc 'Deployment task: rename_smartest_energy_data_feed_config'
  task rename_smartest_energy_data_feed_config: :environment do
    puts "Running deploy task 'rename_smartest_energy_data_feed_config'"

    amr_data_feed_config = AmrDataFeedConfig.find_by(identifier: 'smartestenergy')
    amr_data_feed_config.update!(description: 'SmartestEnergy Stark daily', identifier: 'smartestenergy-stark')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
