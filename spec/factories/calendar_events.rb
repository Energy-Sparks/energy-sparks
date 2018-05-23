FactoryBot.define do
  factory :calendar_event do
    factory :term do
      association :calendar_event_type, term_time: true
    end
  end
end