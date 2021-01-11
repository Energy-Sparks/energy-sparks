namespace :after_party do
  desc 'Deployment task: update_staff_roles'
  task update_staff_roles: :environment do
    puts "Running deploy task 'update_staff_roles'"

    # Put your task implementation HERE.
    StaffRole.where(title: 'LA or MAT advisor').update(title: 'Council or MAT staff')
    StaffRole.where(title: 'Parent').update(title: 'Parent or volunteer')
    StaffRole.where(title: 'Third party/Other').update(title: 'Public')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
