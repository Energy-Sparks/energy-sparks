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
      association :observable, factory: :audit
    end

    trait :audit_activities_completed do
      observation_type { :audit_activities_completed }
      association :observable, factory: :audit
    end

    trait :intervention do
      observation_type { :intervention }
      intervention_type
    end

    trait :intervention_with_image_in_description do
      intervention
      description { 'default description' }

      after(:build) do |observation|
        file = Rails.root.join('spec/fixtures/images/placeholder.png')

        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(file),
          filename: 'placeholder.png',
          content_type: 'image/png'
        )

        attachment_html = ActionText::Attachment.from_attachable(blob).to_html
        observation.description = ActionText::Content.new("<div>#{attachment_html}</div>")
      end
    end

    trait :programme do
      observation_type { :programme }
      association :observable, factory: :programme
    end

    trait :temperature do
      observation_type { :temperature }
      to_create { |instance| TemperatureObservationCreator.new(instance).process }
    end

    trait :transport_survey do
      observation_type { :transport_survey }
      association :observable, factory: :transport_survey
    end

    trait :school_target do
      observation_type { :school_target }
      association :observable, factory: :school_target
    end

    trait :with_contributors do
      created_by { association :user }
      updated_by { association :user }
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
