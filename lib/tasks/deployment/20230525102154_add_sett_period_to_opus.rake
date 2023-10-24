namespace :after_party do
  desc 'Deployment task: add_sett_period_to_opus'
  task add_sett_period_to_opus: :environment do
    puts "Running deploy task 'add_sett_period_to_opus'"

    identifier = "opus-hh"
    amr_data_feed_config = AmrDataFeedConfig.find_by(identifier: identifier)
    if amr_data_feed_config
      amr_data_feed_config.update!(period_field: 'Sett Period')
    end


    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
