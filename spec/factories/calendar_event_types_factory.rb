FactoryBot.define do
  factory :calendar_event_type do
    trait :holiday do
      holiday true
    end
    trait :term_time do
      term_time true
    end
  end
end
