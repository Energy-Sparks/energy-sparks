namespace :after_party do
  desc 'Deployment task: add_meter_breakdown_feature'
  task add_meter_breakdown_feature: :environment do
    puts "Running deploy task 'add_meter_breakdown_feature'"

    Flipper.add(:meter_breakdowns)
    Flipper.enable_group(:meter_breakdowns, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
