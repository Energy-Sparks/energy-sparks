namespace :after_party do
  desc 'Deployment task: accept_terms_for_onboarding_users'
  task accept_terms_for_onboarding_users: :environment do
    puts "Running deploy task 'accept_terms_for_onboarding_users'"

    # Find users who were responsible for onboarding their school, where we have not already
    # marked that they accepted terms and update them accordingly. The form required acceptance
    # but was not logging it.
    User
      .joins('INNER JOIN school_onboardings ON school_onboardings.created_user_id = users.id')
      .joins('INNER JOIN school_onboarding_events ON school_onboarding_events.school_onboarding_id = school_onboardings.id')
      .where(terms_accepted: false)
      .where(school_onboarding_events: { event: SchoolOnboardingEvent.events[:onboarding_user_created] })
      .distinct.update_all(terms_accepted: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
