FactoryBot.define do
  factory :school_group do
    sequence(:name) {|n| "School group #{n}"}
    public { true }

    trait :with_active_schools do
      transient do
        count { 1 }
      end

      after(:build) do |school_group, evaluator|
        school_group.schools = create_list(:school, evaluator.count, school_group: school_group, active: true, public: true)
      end
    end
  end
end
