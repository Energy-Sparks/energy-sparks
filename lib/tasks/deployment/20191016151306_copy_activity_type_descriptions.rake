namespace :after_party do
  desc 'Deployment task: copy_activity_type_descriptions'
  task copy_activity_type_descriptions: :environment do
    puts "Running deploy task 'copy_activity_type_descriptions'"

    # Put your task implementation HERE.
    ActivityType.all.each do |activity_type|
      activity_type.update(school_specific_description: activity_type.description)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
