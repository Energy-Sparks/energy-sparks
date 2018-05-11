FactoryBot.define do
  factory :activity_type do
    activity_category
    sequence(:name) {|n| "test activity_type name #{n}"}
    score 25
    active true
    data_driven true
    repeatable true
    description 'test_activity_type description'

    trait :as_initial_suggestions do
      after(:create) do |activity_type, evaluator|
        create :activity_type_suggestion, suggested_type: activity_type
      end
    end

    trait :with_further_suggestions do
      transient do
        number_of_suggestions 1
      end

      after(:create) do |original_activity_type, evaluator|
        evaluator.number_of_suggestions.times do |index|
          blah = create :activity_type
          create :activity_type_suggestion, activity_type: original_activity_type, suggested_type: blah
      end
      end
    end
  end
end
