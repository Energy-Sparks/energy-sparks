namespace :after_party do
  desc 'Deployment task: populate_activity_created_by'
  task populate_activity_created_by: :environment do
    puts "Running deploy task 'populate_activity_created_by'"

    # Ensure the two models are synchronised, avoid running callbacks to just
    # update the fields.
    Observation.activity.find_each do |observation|
      if observation.activity # around 18 records where there's no association
        observation.activity.update_column(:created_by_id, observation.created_by_id)
        observation.update_column(:updated_by_id, observation.activity.updated_by_id)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
