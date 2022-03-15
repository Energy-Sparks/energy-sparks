namespace :after_party do
  desc 'Deployment task: remove_programme_activity_without_activity'
  task remove_programme_activity_without_activity: :environment do
    puts "Running deploy task 'remove_programme_activity_without_activity'"

    # Put your task implementation HERE.
    ProgrammeActivity.where(activity_id: nil).delete_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
