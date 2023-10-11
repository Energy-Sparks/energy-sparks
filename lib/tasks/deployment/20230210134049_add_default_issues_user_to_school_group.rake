namespace :after_party do
  desc 'Deployment task: add_default_issues_user_to_school_group'
  task add_default_issues_user_to_school_group: :environment do
    puts "Running deploy task 'add_default_issues_user_to_school_group'"

    default_user = User.find_by(email: 'rebecca.scutt@energysparks.uk')
    SchoolGroup.where(default_issues_admin_user: nil).update_all(default_issues_admin_user_id: default_user.id)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
