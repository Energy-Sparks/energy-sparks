namespace :after_party do
  desc 'Deployment task: resynchronize_inactive_users'
  task resynchronize_inactive_users: :environment do
    puts "Running deploy task 'resynchronize_inactive_users'"

    # Find all users who aren't pupils or school_onboarding, which have been
    # synchronised to Mailchimp and are marked as inactive and touch the timestamp
    # used to drive synchronisation with Mailchimp
    #
    # Will ensure that inactive users are updated in Mailchimp following changes to
    # how we classify these users.
    User.mailchimp_roles.where.not(mailchimp_status: nil, active: false).touch(:mailchimp_fields_changed_at)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
