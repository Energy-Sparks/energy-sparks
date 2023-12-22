FactoryBot.define do
  factory :observation do
    school            { create(:school) }
    at                { Time.now.utc }

    trait :activity do
      observation_type { :activity }
      activity
    end

    trait :audit do
      observation_type { :audit }
      audit
    end

    trait :audit_activities_completed do
      observation_type { :audit_activities_completed }
      audit
    end

    trait :intervention do
      observation_type { :intervention }
      intervention_type
    end

    trait :programme do
      observation_type { :observable }
      association :observable, factory: :programme
    end

    trait :temperature do
      observation_type { :temperature }
      to_create { |instance| TemperatureObservationCreator.new(instance).process }
    end

    trait :transport_survey do
      observation_type { :observable }
      association :observable, factory: :transport_survey
    end

    trait :school_target do
      observation_type { :school_target }
      association :observable, factory: :school_target
    end

    factory :observation_with_temperature_recording_and_location do
      observation_type { :temperature }
      after(:create) do |observation, _evaluator|
        location = create(:location, school: observation.school)
        create(:temperature_recording, observation: observation, location: location)
      end
    end
  end
end
