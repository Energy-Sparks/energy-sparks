FactoryBot.define do
  factory :observation do
    school            { create(:school) }
    at                { Time.now.utc }

    trait :temperature do
      observation_type { :temperature }
      to_create { |instance| TemperatureObservationCreator.new(instance).process }
    end

    trait :intervention do
      observation_type { :intervention }
      intervention_type
    end

    trait :activity do
      observation_type { :activity }
      activity
    end

    factory :observation_with_temperature_recording_and_location do
      observation_type { :temperature }
      after(:create) do |observation, evaluator|
        location = create(:location, school: observation.school)
        create(:temperature_recording, observation: observation, location: location)
      end
    end
  end
end
