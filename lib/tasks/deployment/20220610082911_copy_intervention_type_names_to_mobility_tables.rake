namespace :after_party do
  desc 'Deployment task: copy_intervention_type_names_to_mobility_tables'
  task copy_intervention_type_names_to_mobility_tables: :environment do
    puts "Running deploy task 'copy_intervention_type_names_to_mobility_tables'"

    InterventionType.transaction do
      InterventionType.all.each do |intervention_type|
        intervention_type.update(name: intervention_type.read_attribute(:name))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
