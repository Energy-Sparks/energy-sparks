namespace :after_party do
  desc 'Deployment task: retire_british_gas_feeds'
  task retire_british_gas_feeds: :environment do
    puts "Running deploy task 'retire_british_gas_feeds'"

    AmrDataFeedConfig.where(
      identifier: ['british-gas', 'british-gas-portal-gas', 'british-gas-portal-electricity']
    ).update_all(enabled: false)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
