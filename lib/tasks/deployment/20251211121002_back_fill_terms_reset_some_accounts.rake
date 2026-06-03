namespace :after_party do
  desc 'Deployment task: back_fill_terms_reset_some_accounts'
  task back_fill_terms_reset_some_accounts: :environment do
    puts "Running deploy task 'back_fill_terms_reset_some_accounts'"

    # We do this first to ensure they're not included in the second update
    #
    # Find all adult and student role accounts that are marked as confirmed
    # but where both mailchimp status and encrypted password fields are nil.
    #
    # This indicates that user has not filled in a registration form and has not
    # subsequently done a password reset in order to login.
    #
    # These users should not be marked as confirmed.
    User.where.not(role: %i[pupil school_onboarding])
        .where.not(confirmed_at: nil)
        .where(mailchimp_status: nil, encrypted_password: '').find_each do |user|
      # Mark them as not actually confirmed, so they can re-register
      user.update(confirmed_at: nil)
      # ...and reissue the emails
      user.send_confirmation_instructions
    end

    # Find all adult and student role accounts that are confirmed and backfill
    # the terms_accepted field to indicate they have registered and ticked the box
    User.where.not(role: %i[pupil school_onboarding])
        .where.not(confirmed_at: nil)
        .update_all(terms_accepted: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
