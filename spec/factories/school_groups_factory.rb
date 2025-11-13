FactoryBot.define do
  factory :school_group do
    sequence(:name) {|n| "School group #{n}"}
    default_issues_admin_user { create(:admin) }
    public { true }

    trait :project_group do
      group_type { :project }
    end

    trait :diocese do
      group_type { :diocese }
    end

    trait :local_authority_area do
      group_type { :local_authority_area }
    end

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
        case school_group.group_type.to_sym
        when :project
          school_group.project_schools = create_list(:school, evaluator.count, :with_project, group: school_group, active: true, public: true)
        when :local_authority_area
          school_group.area_schools = create_list(:school, evaluator.count, :with_local_authority_area, group: school_group, active: true, public: true)
        when :diocese
          school_group.area_schools = create_list(:school, evaluator.count, :with_diocese, group: school_group, active: true, public: true)
        else
          school_group.schools = create_list(:school, evaluator.count, school_group: school_group, active: true, public: true)
        end
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
