namespace :after_party do
  desc 'Deployment task: update_school_group_group_types'
  task update_school_group_group_types: :environment do
    puts "Running deploy task 'update_school_group_group_types'"

    SchoolGroup.where("lower(name) like '%trust%'").update_all(group_type: :multi_academy_trust)
    SchoolGroup.where("lower(name) like '%partnership%'").update_all(group_type: :multi_academy_trust)

    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end