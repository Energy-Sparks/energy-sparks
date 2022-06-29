namespace :after_party do
  desc 'Deployment task: copy_intervention_type_group_attributes_to_mobility_tables'
  task copy_intervention_type_group_attributes_to_mobility_tables: :environment do
    puts "Running deploy task 'copy_intervention_type_group_attributes_to_mobility_tables'"

    InterventionTypeGroup.transaction do
      InterventionTypeGroup.all.each do |group|
        group.update(name: group.read_attribute(:name))
        group.update(description: group.read_attribute(:description))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
