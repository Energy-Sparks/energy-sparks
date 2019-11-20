namespace :after_party do
  desc 'Deployment task: add_creation_events_to_schools'
  task add_creation_events_to_schools: :environment do
    puts "Running deploy task 'add_creation_events_to_schools'"

    School.all.each do |school|
      school.observations.create!(
        description: "#{school.name} joined Energy Sparks!",
        at: school.created_at,
        observation_type: :event
      )
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
