namespace :after_party do
  desc 'Deployment task: update_the_brain'
  task update_the_brain: :environment do
    puts "Running deploy task 'update_the_brain'"

    # Put your task implementation HERE.
    InterventionTypeGroup.find_by(icon: 'head-side-brain').update(icon: 'users')
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
