namespace :after_party do
  desc 'Deployment task: touch_all_activity_types'
  task touch_all_activity_types: :environment do
    puts "Running deploy task 'touch_all_activity_types'"

    # Touch all activity type records so we can resync with Transifex
    ActivityType.touch_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end