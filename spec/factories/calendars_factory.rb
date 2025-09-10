FactoryBot.define do
  factory :calendar do
    title { 'Test Calendar' }
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

    trait :based_on_regional do
      transient do
        regional_title { 'regional calendar' }
      end

      after(:create) do |calendar, evaluator|
        regional_calendar = create(:regional_calendar,
                                   :with_academic_years,
                                   title: evaluator.regional_title)

        calendar.update!(based_on: regional_calendar)
      end
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

    # Ensures there is a previous, current and upcoming AcademicYear
    trait :with_previous_and_next_academic_years do
      after(:create) do |calendar, _evaluator|
        today = Time.zone.today
        # At the end of the year, school academic year started in previous year
        # But otherwise, the previous academic year started 2 years ago
        start_year = today.year - (today.month < 9 ? 2 : 1)
        end_year = today.year + 1
        (start_year..end_year).each do |year|
          create(:academic_year, calendar: calendar, start_date: Date.new(year, 9, 1), end_date: Date.new(year + 1, 8, 31))
        end
      end
    end

    trait :with_terms_and_holidays do
      transient do
        term_start_date { 1.year.ago }
        term_count { 5 }
        term_length { 6 } # length of each term in weeks
        holiday_length { 2 } # length of each holiday in weeks
      end

      after(:create) do |calendar, evaluator|
        term_start = evaluator.term_start_date
        evaluator.term_count.times do |_i|
          term_end = term_start + evaluator.term_length.weeks
          holiday_start = term_end + 1
          holiday_end = holiday_start + evaluator.holiday_length.weeks
          create(:term, calendar: calendar, start_date: term_start, end_date: term_end)
          create(:calendar_event_holiday, calendar: calendar, start_date: holiday_start, end_date: holiday_end)
          term_start = holiday_end + 1
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
