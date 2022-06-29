namespace :after_party do
  desc 'Deployment task: copy_activity_category_attributes_to_mobility_tables'
  task copy_activity_category_attributes_to_mobility_tables: :environment do
    puts "Running deploy task 'copy_activity_category_attributes_to_mobility_tables'"

    # Put your task implementation HERE.
    ActivityCategory.transaction do
      ActivityCategory.all.each do |activity_category|
        activity_category.update(name: activity_category.read_attribute(:name))
        activity_category.update(description: activity_category.read_attribute(:description))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
