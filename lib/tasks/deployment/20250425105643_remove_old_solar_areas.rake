namespace :after_party do
  desc 'Deployment task: remove_old_solar_areas'
  task remove_old_solar_areas: :environment do
    puts "Running deploy task 'remove_old_solar_areas'"

    # Remove all of the old areas, where we've set gsp id to nil
    # The readings are no longer valid, so remove everything.
    SolarPvTuosArea.where(gsp_id: nil).destroy_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
