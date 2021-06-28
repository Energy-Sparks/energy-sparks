namespace :after_party do
  desc 'Deployment task: onboarding_newsletter'
  task onboarding_newsletter: :environment do
    puts "Running deploy task 'onboarding_newsletter'"

    SchoolOnboarding.all.each do |onboarding|
      if onboarding.incomplete? && onboarding.created_user.present? && onboarding.subscribe_to_newsletter
        onboarding.update!(subscribe_users_to_newsletter: [onboarding.created_user.id])
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
