namespace :after_party do
  desc 'Deployment task: fix_roles_for_cluster_admins'
  task fix_roles_for_cluster_admins: :environment do
    puts "Running deploy task 'fix_roles_for_cluster_admins'"

    User.active.staff.joins(:cluster_schools).distinct.update_all(role: :school_admin)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
