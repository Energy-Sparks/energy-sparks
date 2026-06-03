namespace :after_party do
  desc 'Deployment task: remove_unconfirmed_users_from_archived'
  task remove_unconfirmed_users_from_archived: :environment do
    puts "Running deploy task 'remove_unconfirmed_users_from_archived'"

    # find all unconfirmed users that are associated with a school which is not
    # active. This will include both archived and deleted schools
    User.joins(:school).where(confirmed_at: nil).where(schools: { active: false }).destroy_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
