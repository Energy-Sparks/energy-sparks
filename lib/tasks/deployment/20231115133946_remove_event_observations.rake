namespace :after_party do
  desc 'Deployment task: remove_event_observations'
  task remove_event_observations: :environment do
    puts "Running deploy task 'remove_event_observations'"

    #remove instance of the :event Observation as its not longer needed/used
    #use the enum id and call delete all to avoid instantiating the objects
    #as :event has been removed as a valid enum value
    Observation.where("observation_type = 3").delete_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
