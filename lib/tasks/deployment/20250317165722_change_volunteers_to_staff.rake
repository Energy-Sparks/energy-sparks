namespace :after_party do
  desc 'Deployment task: change_volunteers_to_staff'
  task change_volunteers_to_staff: :environment do
    puts "Running deploy task 'change_volunteers_to_staff'"

    # There are only 2-3 volunteers. This is first step in replacing the role
    User.volunteer.update_all(role: :staff, staff_role_id: StaffRole.find_by(title: 'Parent or volunteer')&.id)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
