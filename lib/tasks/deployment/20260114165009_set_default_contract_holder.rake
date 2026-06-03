namespace :after_party do
  desc 'Deployment task: set_default_contract_holder'
  task set_default_contract_holder: :environment do
    puts "Running deploy task 'set_default_contract_holder'"

    School.includes(:school_group).find_each do |school|
      school.update!(default_contract_holder: school.organisation_group)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
