FactoryBot.define do
  factory :observation do
    school           { create(:school) }
    observation_type { :intervention }
    at               { Time.now.utc }

    trait :temperature do
      observation_type { :temperature }
      to_create { |instance| TemperatureObservationCreator.new(instance).process }
    end

    trait :intervention do
      observation_type { :intervention }
      intervention_type { intervention_type }
    end

    factory :observation_with_temperature_recording_and_location do
      after(:create) do |observation, evaluator|
        location = create(:location, school: observation.school)
        create(:temperature_recording, observation: observation, location: location)
      end
    end
  end
end
