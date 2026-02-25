namespace :after_party do
  desc 'Deployment task: update_school_onboardings'
  task update_school_onboardings: :environment do
    puts "Running deploy task 'update_school_onboardings'"

    SchoolOnboarding.incomplete.where.not(urn: nil).find_each do |onboarding|
      onboarding.assign_attributes({
        diocese: onboarding.find_group(group_type: :diocese, code_attr: :diocese_code),
        local_authority_area: onboarding.find_group(group_type: :local_authority_area, code_attr: :la_code)
      })
      unless onboarding.save
        puts "Cannot save onboarding #{onboarding.id} #{onboarding.name}"
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
