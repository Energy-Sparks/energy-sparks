namespace :after_party do
  desc 'Deployment task: remove_duplicate_school_target_observations'
  task remove_duplicate_school_target_observations: :environment do
    puts "Running deploy task 'remove_duplicate_school_target_observations'"

    SchoolTarget.all.each do |school_target|
      obs = Observation.where(school_target: school_target).order(created_at: :desc)
      if obs.length > 1
        obs[0..-2].each do |obs| obs.destroy end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
