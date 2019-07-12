FactoryBot.define do
  factory :calendar do
    title { "Test Calendar" }
    default { false }
    template { true }

    factory :calendar_with_terms do
      # posts_count is declared as a transient attribute and available in
      # attributes on the factory, as well as the callback via the evaluator
      transient do
        posts_count { 5 }
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including transient
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the user is associated properly to the post
      after(:create) do |calendar, evaluator|
        evaluator.posts_count.times do |i|
          create(:term, calendar: calendar, start_date: i.weeks.from_now, end_date: (i.weeks.from_now + 6.days))
        end
      end
    end

  end
end
