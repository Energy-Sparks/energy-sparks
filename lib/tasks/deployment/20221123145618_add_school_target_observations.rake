namespace :after_party do
  desc 'Deployment task: add_school_target_observations'
  task add_school_target_observations: :environment do
    puts "Running deploy task 'add_school_target_observations'"

    #Create an observation for every existing target in the system
    SchoolTarget.all.each do |school_target|
      Observation.create!(
        school: school_target.school,
        observation_type: :school_target,
        school_target: school_target,
        at: school_target.start_date,
        points: 0
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
