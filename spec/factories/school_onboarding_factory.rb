require 'securerandom'
FactoryBot.define do
  factory :school_onboarding do
    uuid                      { SecureRandom.uuid }
    sequence(:school_name)    { |n| "New School #{n}" }
    sequence(:contact_email)  { |n| "new_school_#{n}@test.com" }
    school_group

    trait :with_events do
      transient do
        event_names { [] }
      end

      after(:build) do |onboarding, evaluator|
        onboarding.events = evaluator.event_names.map{|event_name| onboarding.events.build(event: event_name) }
      end
    end
  end
end
