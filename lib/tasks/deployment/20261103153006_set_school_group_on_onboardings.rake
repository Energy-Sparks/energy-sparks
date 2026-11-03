# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: set_school_group_on_onboardings'
  task set_school_group_on_onboardings: :environment do
    puts "Running deploy task 'set_school_group_on_onboardings'"

    # School Group is now required. Assign a school group to onboardings that have been created
    # without one based on the onboarding school.
    SchoolOnboarding.where(school_group: nil).where.not(school: nil).find_each do |onboarding|
      onboarding.update(school_group: onboarding.school.school_group)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
