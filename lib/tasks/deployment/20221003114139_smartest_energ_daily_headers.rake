namespace :after_party do
  desc 'Deployment task: Revise header rows'
  task smartest_energ_daily_headers: :environment do
    puts "Running deploy task 'smartest_energ_daily_headers'"

    amr_data_feed_config = AmrDataFeedConfig.find_by(identifier: 'smartestenergy-stark')
    amr_data_feed_config.update!(number_of_header_rows: 8) if amr_data_feed_config

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
