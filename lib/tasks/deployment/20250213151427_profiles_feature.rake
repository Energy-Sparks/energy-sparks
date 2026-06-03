namespace :after_party do
  desc 'Deployment task: profiles_feature'
  task profiles_feature: :environment do
    puts "Running deploy task 'profiles_feature'"

    Flipper.add(:profile_pages)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
