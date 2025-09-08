FactoryBot.define do
  factory :programme_type do
    sequence(:title)              { |n| "Programme Type title #{n}"}
    sequence(:description)        { |n| "Programme Type description #{n}"}
    sequence(:short_description)  { |n| "Programme Type short description #{n}"}
    sequence(:document_link)      { |n| "http://example.org/document#{n}.pdf" }
    active                              { true }

    trait :with_todos do
      after(:create) do |programme_type, _evaluator|
        create_list(:activity_type_todo, 3, assignable: programme_type)
        create_list(:intervention_type_todo, 3, assignable: programme_type)
      end
    end

    trait :with_activity_type_todos do
      after(:create) do |programme_type, _evaluator|
        create_list(:activity_type_todo, 3, assignable: programme_type)
      end
    end

    trait :with_intervention_type_todos do
      after(:create) do |programme_type, _evaluator|
        create_list(:intervention_type_todo, 3, assignable: programme_type)
      end
    end

    # old way - remove when :todos feature removed
    factory :programme_type_with_activity_types do
      transient do
        count { 3 }
      end

      after(:create) do |programme_type, evaluator|
        evaluator.count.times.each do |counter|
          activity_type = create(:activity_type)
          ProgrammeTypeActivityType.create(programme_type: programme_type, activity_type: activity_type, position: counter)
        end
      end
    end
  end
end
