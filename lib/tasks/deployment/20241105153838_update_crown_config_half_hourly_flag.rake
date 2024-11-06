namespace :after_party do
  desc 'Deployment task: update_crown_config_half_hourly_flag'
  task update_crown_config_half_hourly_flag: :environment do
    puts "Running deploy task 'update_crown_config_half_hourly_flag'"

    AmrDataFeedConfig.where(identifier: 'crown-row').update_all(half_hourly_labelling: :end)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
