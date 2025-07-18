namespace :after_party do
  desc 'Deployment task: add_half_hourly_labelling_to_edf'
  task add_half_hourly_labelling_to_edf: :environment do
    puts "Running deploy task 'add_half_hourly_labelling_to_edf'"

    AmrDataFeedConfig.where(identifier: :edf).update_all(half_hourly_labelling: :start)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
