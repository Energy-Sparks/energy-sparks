namespace :after_party do
  desc 'Deployment task: update_headteacher_role'
  task update_headteacher_role: :environment do
    puts "Running deploy task 'update_headteacher_role'"

    StaffRole.where(title: 'Headteacher').update_all(title: 'Headteacher or Deputy Head')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
