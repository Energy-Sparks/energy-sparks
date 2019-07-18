FactoryBot.define do
  factory :programme_type do
    sequence(:title) {|n| "Programme Type #{n}"}

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