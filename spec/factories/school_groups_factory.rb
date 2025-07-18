FactoryBot.define do
  factory :school_group do
    sequence(:name) {|n| "School group #{n}"}
    default_issues_admin_user { create(:admin) }
    public { true }

    trait :with_default_scoreboard do
      after(:create) do |school_group, _evaluator|
        school_group.update(default_scoreboard: create(:scoreboard))
      end
    end

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
