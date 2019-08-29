FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@test.com" }
    password         { 'testpass' }
    confirmed_at     { Time.zone.now }

    factory :school_admin  do
      role { :school_admin }
    end

    factory :pupil do
      role { :pupil }
      pupil_password { 'test' }
    end

    factory :staff do
      name { 'A Teacher' }
      role { :staff }
    end

    factory :admin do
      role { :admin }
    end

    trait :has_school_assigned do
      school
    end
  end
end
