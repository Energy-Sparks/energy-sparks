namespace :after_party do
  desc 'Deployment task: Revise sse-dukefield filters'
  task revise_dukefield_filters: :environment do
    puts "Running deploy task 'revise_dukefield_filters'"

    amr_data_feed_config = AmrDataFeedConfig.find_by(identifier: 'sse-dukefield-energy')
    amr_data_feed_config.update!(column_row_filters: { 'Description' => '^Reactive Energy|^Volume' })

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
