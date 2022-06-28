namespace :after_party do
  desc 'Deployment task: copy_summaries_to_mobility_tables'
  task copy_summaries_to_mobility_tables: :environment do
    puts "Running deploy task 'copy_summaries_to_mobility_tables'"

    # Put your task implementation HERE.
    ActivityType.transaction do
      ActivityType.all.each do |activity_type|
        activity_type.update(summary: activity_type.read_attribute(:summary))
      end
    end

    InterventionType.transaction do
      InterventionType.all.each do |intervention_type|
        intervention_type.update(summary: intervention_type.read_attribute(:summary))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
