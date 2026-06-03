namespace :after_party do
  desc 'Deployment task: find_new_group_types'
  task find_new_group_types: :environment do
    puts "Running deploy task 'find_new_group_types'"

    Flipper.add(:find_new_group_types)
    Flipper.enable_group(:find_new_group_types, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
