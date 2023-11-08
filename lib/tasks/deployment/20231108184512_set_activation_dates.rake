namespace :after_party do
  desc 'Deployment task: set_activation_dates'
  task set_activation_dates: :environment do
    puts "Running deploy task 'set_activation_dates'"

    SchoolOnboarding.complete.each do |school_onboarding|
      unless school_onboarding.school.activation_date.present?
        school_onboarding.school.update!(activation_date: school_onboarding.first_made_data_enabled)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
