FactoryBot.define do
  factory :calendar do
    title { "Test Calendar" }
    calendar_type { :school }

    factory :template_calendar do
      calendar_type { :regional }
      with_terms
    end

    factory :school_calendar do
      calendar_type { :school }
      with_academic_years
    end

    factory :regional_calendar do
      calendar_type { :regional }

      transient do
        national_title { 'national calendar' }
      end

      after(:create) do |calendar, evaluator|
        national_calendar = create(:national_calendar, :with_academic_years, title: evaluator.national_title)
        calendar.update!(based_on: national_calendar)
      end
    end

    factory :national_calendar do
      calendar_type { :national }
    end

    trait :with_academic_years do
      transient do
        academic_year_count { 1 }
      end

      after(:create) do |calendar, evaluator|
        evaluator.academic_year_count.times do |_i|
          create(:academic_year, calendar: calendar)
        end
      end
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
