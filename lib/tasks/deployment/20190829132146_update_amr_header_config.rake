namespace :after_party do
  desc 'Deployment task: update_amr_header_config'
  task update_amr_header_config: :environment do
    puts "Running deploy task 'update_amr_header_config'"

    # Put your task implementation HERE.
    AmrDataFeedConfig.where(description: 'Sheffield').update(number_of_header_rows: 1)
    AmrDataFeedConfig.where(description: 'Sheffield Historical Gas').update(number_of_header_rows: 1)
    AmrDataFeedConfig.where(description: 'Sheffield Gas').update(number_of_header_rows: 1)
    AmrDataFeedConfig.where(description: 'Frome Historical').update(number_of_header_rows: 1)
    AmrDataFeedConfig.where(description: 'Banes').update(number_of_header_rows: 1)
    AmrDataFeedConfig.where(description: 'Highlands Historic').update(number_of_header_rows: 1)

    AmrDataFeedConfig.where(description: 'Frome').update(number_of_header_rows: 0)
    AmrDataFeedConfig.where(description: 'Stark (Oxfordshire etc)').update(number_of_header_rows: 0)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end