FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@test.com" }
    password         { 'testpass' }
    confirmed_at     { Time.zone.now }

    factory :school_admin  do
      role { :school_admin }
      association :staff_role, factory: [:staff_role, :management]
      school
    end

    factory :pupil do
      role { :pupil }
      pupil_password { 'test' }
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
      role { :admin }
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
