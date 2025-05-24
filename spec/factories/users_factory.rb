FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@test.com" }
    sequence(:password) { |n| "secure password phrase #{n}" }
    sequence(:name) { |n| "user #{n}" }
    confirmed_at { Time.zone.now }

    factory :school_admin do
      name { 'School manager' }
      role { :school_admin }
      association :staff_role, factory: [:staff_role, :management]
      school

      trait :with_cluster_schools do
        transient do
          count { 1 }
          existing_school { nil }
        end

        after(:build) do |user, evaluator|
          user.cluster_schools = create_list(:school, evaluator.count, active: true, public: true)
          user.cluster_schools << user.school
          user.cluster_schools << evaluator.existing_school if evaluator.existing_school
        end
      end
    end

    factory :pupil do
      role { :pupil }
      pupil_password { 'three memorable words' }
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

    factory :analytics do
      name { 'Analytics'}
      role { :analytics }
    end

    factory :guest do
      role { :guest }
    end

    factory :group_admin do
      name { 'Group admin'}
      role { :group_admin }
      school_group
    end

    trait :has_school_assigned do
      school
    end

    trait :skip_confirmed do
      after(:build) do |user, _evaluator|
        user.skip_confirmation_notification!
      end
    end

    trait :subscribed_to_alerts do
      after(:build) do |user, _evaluator|
        user.contacts << create(:contact_with_name_email_phone, school: user.school)
      end
    end
  end
end
