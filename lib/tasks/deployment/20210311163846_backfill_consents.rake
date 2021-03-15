namespace :after_party do
  desc 'Deployment task: Backfill existing consent data'
  task backfill_consents: :environment do
    puts "Running deploy task 'backfill_consents'"

    statement = ConsentStatement.first

    #loop through all schools
    School.all.each do |school|
      if school.consent_grants.any?
        puts "Skipping #{school.name}. Consent grants already exist"
      else
        user = school.school_admin.first || school.school_admin.first
        #assume consent given at at point of registration
        #using this as some school recorded were created dates/months before
        #any users
        created_at = user.created_at if user.present?

        #use details from the onboarding process and events to fill in the grant
        if school.school_onboarding.present?
          onboarding = school.school_onboarding
          #some schools with onboarding don't have a created user
          user = onboarding.created_user || school.school_admin.first
          #find permission_given event
          permission_event = onboarding.events.where(event: SchoolOnboardingEvent.events[:permission_given]).first
          #use the event date if found, otherwise default to when user created
          created_at = permission_event.present? ? permission_event.created_at : user.created_at
        end

        if user
          ConsentGrant.create!(
            consent_statement: statement,
            school: school,
            user: user,
            name: user.name,
            job_title: nil,
            school_name: school.name,
            created_at: created_at
          )
          puts "Created Consent Grant for #{school.name}"
        else
          puts "Skipped #{school.name} #{school.id} no onboarding user or school admin"
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
