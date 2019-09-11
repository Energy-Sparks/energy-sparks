FactoryBot.define do
  factory :calendar do
    title { "Test Calendar" }
    default { false }
    template { true }
    calendar_type { :school }
    calendar_area

    factory :school_calendar do
      calendar_type { :school }
    end

    factory :regional_calendar do
      calendar_type { :regional }
    end

    factory :national_calendar do
      calendar_type { :national }
    end

    trait :with_terms do
      transient do
        term_count { 5 }
      end

      after(:create) do |calendar, evaluator|
        evaluator.term_count.times do |i|
          create(:term, calendar: calendar, start_date: i.weeks.from_now, end_date: (i.weeks.from_now + 6.days))
        end
      end
    end
  end
end
