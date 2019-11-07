FactoryBot.define do
  factory :school do
    sequence(:urn)
    sequence(:number_of_pupils)
    sequence(:name) { |n| "test #{n} school" }
    school_type     { :primary }
    visible         { true }
    process_data    { true }
    address         { '1 Station Road' }
    postcode        { 'ab1 2cd' }
    floor_area      { BigDecimal("1234.567")}
    website         { "http://#{name.camelize}.test" }
    calendar        { create(:school_calendar) }

    after(:build) do |school, _evaluator|
      build(:configuration, school: school)
    end

    factory :school_with_same_name do
      name { "test school"}
    end

    trait :with_school_group do
      after(:create) do |school, evaluator|
        school.update(school_group: create(:school_group))
      end
    end

    trait :with_calendar do
      after(:create) do |school, evaluator|
        school.update(calendar: create(:school_calendar))
      end
    end

    trait :with_feed_areas do
      after(:create) do |school, evaluator|
        school.update(dark_sky_area: create(:dark_sky_area), solar_pv_tuos_area: create(:solar_pv_tuos_area))
      end
    end

    trait :with_points do

      transient do
        score_points { 1 }
        activities_happened_on { 1.month.ago }
      end

      after(:create) do |school, evaluator|
        activity_type = create(:activity_type, score: evaluator.score_points)
        create(:activity, school: school, activity_type: activity_type, happened_on: evaluator.activities_happened_on)
      end
    end
  end
end
