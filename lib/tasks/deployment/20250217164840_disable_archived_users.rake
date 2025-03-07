namespace :after_party do
  desc 'Deployment task: disable_archived_users'
  task disable_archived_users: :environment do
    puts "Running deploy task 'disable_archived_users'"

    # We previously locked users when archiving schools, but we not have the active flag
    # Find all locked school users, who are linked to inactive (archived, removed) schools
    # Do not want to disable any temporarily locked accounts
    User.joins(:school).where(role: [:pupil, :staff, :school_admin, :volunteer]).where.not(locked_at: nil).where(schools: { active: false }).update_all(active: false)

    # Find all group_admins that are locked, and disable them if every school in the group has
    # been removed

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
