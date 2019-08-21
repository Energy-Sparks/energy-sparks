FactoryBot.define do
  factory :observation do
    school           { create(:school)}
    observation_type { :temperature }
    at               { Time.now.utc }

    to_create { |instance| TemperatureObservationCreator.new(instance).process }

    trait :intervention do
      observation_type { :intervention }
      intervention_type
      to_create { |instance| InterventionCreator.new(instance).process }
    end

    factory :observation_with_temperature_recording_and_location do
      after(:create) do |observation, evaluator|
        location = create(:location, school: observation.school)
        create(:temperature_recording, observation: observation, location: location)
      end
    end
  end
end
