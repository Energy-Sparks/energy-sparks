namespace :after_party do
  desc 'Deployment task: backfill_programme_observations'
  task backfill_programme_observations: :environment do
    puts "Running deploy task 'backfill_programme_observations'"

    Programme.completed.find_each(&:add_observation)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end