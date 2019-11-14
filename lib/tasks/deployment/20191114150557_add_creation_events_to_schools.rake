namespace :after_party do
  desc 'Deployment task: add_creation_events_to_schools'
  task add_creation_events_to_schools: :environment do
    puts "Running deploy task 'add_creation_events_to_schools'"

    School.all.each do |school|
      if school.school_onboarding
        activation_event = school.school_onboarding.events.where(event: :activation_email_sent).first
        if activation_event
          date = activation_event.created_at
        else
          date = school.created_at
        end
      else
        date = school.created_at
      end
      school.observations.create!(
        description: "#{school.name} joined Energy Sparks!",
        at: date,
        observation_type: :event
      )
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
