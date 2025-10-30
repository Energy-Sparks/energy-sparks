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

    trait :with_grouping do
      transient do
        count { 1 }
        role { :organisation }
        schools { nil }
      end

      after(:build) do |school_group, evaluator|
        schools = evaluator.schools || create_list(:school, evaluator.count, active: true, public: true)
        case evaluator.role
        when :organisation
          school_group.organisation_schools = schools
        when :area
          school_group.area_schools = schools
        else
          school_group.project_schools = schools
        end
      end
    end

    trait :with_partners do
      transient do
        partner_count { 1 }
      end

      after(:build) do |school_group, evaluator|
        school_group.school_group_partners = create_list(:school_group_partner, evaluator.partner_count, school_group:)
      end
    end
  end
end
