namespace :after_party do
  desc 'Deployment task: resynchronize_inactive_users'
  task resynchronize_inactive_users: :environment do
    puts "Running deploy task 'resynchronize_inactive_users'"

    # Find all users who aren't pupils or school_onboarding, which are marked as
    # inactive and have been synchronised to Mailchimp and touch a timestamp on the
    # model
    #
    # Will ensure that inactive users are updated in Mailchimp following changes to
    # how we classify these users.
    User.mailchimp_roles.where(active: false).where.not(mailchimp_status: nil).touch_all(:mailchimp_fields_changed_at)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
