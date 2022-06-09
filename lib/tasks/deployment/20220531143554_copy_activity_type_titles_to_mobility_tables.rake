namespace :after_party do
  desc 'Deployment task: copy_activity_type_titles_to_mobility_tables'
  task copy_activity_type_titles_to_mobility_tables: :environment do
    puts "Running deploy task 'copy_activity_type_titles_to_mobility_tables'"

    ActivityType.transaction do
      ActivityType.all.each do |activity_type|
        activity_type.update(name: activity_type.read_attribute(:name))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
