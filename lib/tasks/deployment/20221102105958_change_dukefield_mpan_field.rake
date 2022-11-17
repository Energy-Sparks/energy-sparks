namespace :after_party do
  desc 'Deployment task: change_dukefield_mpan_field'
  task change_dukefield_mpan_field: :environment do
    puts "Running deploy task 'change_dukefield_mpan_field'"

    amr_data_feed_config = AmrDataFeedConfig.find_by(identifier: 'sse-dukefield-energy')
    amr_data_feed_config.update!(mpan_mprn_field: 'Meter Name')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
