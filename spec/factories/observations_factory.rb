FactoryBot.define do
  factory :observation do
    school
    observation_type { :temperature }
    at               { Time.now.utc }

    factory :observation_with_temperature_recording_and_location do
      after(:create) do |observation, evaluator|
        location = create(:location, school: observation.school)
        create(:temperature_recording, observation: observation, location: location)
      end
    end
  end
end
