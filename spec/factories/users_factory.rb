FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@test.com" }
    password         { 'testpass' }
    confirmed_at     { Time.zone.now }

    factory :school_admin do
      name { 'School manager' }
      role { :school_admin }
      association :staff_role, factory: [:staff_role, :management]
      school

      trait :with_cluster_schools do
        transient do
          count { 1 }
        end

        after(:build) do |user, evaluator|
          user.cluster_schools = create_list(:school, evaluator.count, active: true, public: true)
        end
      end
    end

    factory :pupil do
      role { :pupil }
      pupil_password { 'test' }
      school
    end

    factory :staff do
      name { 'A Teacher' }
      role { :staff }
      association :staff_role, factory: [:staff_role, :teacher]
      school
    end

    factory :onboarding_user do
      name { 'A Teacher' }
      role { :school_onboarding }
      association :staff_role, factory: [:staff_role, :teacher]
    end

    factory :admin do
      name { 'Admin'}
      role { :admin }
    end

    factory :volunteer do
      name { 'Volunteer'}
      role { :volunteer }
      school
    end

    factory :analytics do
      name { 'Analytics'}
      role { :analytics }
    end

    factory :guest do
      role { :guest }
    end

    factory :group_admin do
      role { :group_admin }
      school_group
    end

    trait :has_school_assigned do
      school
    end
  end
end
