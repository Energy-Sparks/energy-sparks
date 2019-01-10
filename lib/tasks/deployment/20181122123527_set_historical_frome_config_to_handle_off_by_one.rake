namespace :after_party do
  desc 'Deployment task: set_historical_frome_config_to_handle_off_by_one'
  task set_historical_frome_config_to_handle_off_by_one: :environment do
    puts "Running deploy task 'set_historical_frome_config_to_handle_off_by_one'"

    # Put your task implementation HERE.
    AmrDataFeedConfig.where(description: 'Frome Historical').update(handle_off_by_one: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20181122123527'
  end
end
