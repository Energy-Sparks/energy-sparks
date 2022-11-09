namespace :after_party do
  desc 'Deployment task: update_british_gas_config'
  task update_british_gas_config: :environment do
    puts "Running deploy task 'update_british_gas_config'"

    # Put your task implementation HERE.
    config = AmrDataFeedConfig.find_by(identifier: 'british-gas')
    config.update!(date_format: '%d/%m/%Y')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end