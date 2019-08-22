FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@test.com" }
    password         { 'testpass' }

    factory :school_admin  do
      role { :school_admin }
    end

    factory :pupil do
      role { :pupil }
      pupil_password { 'test' }
    end

    trait :has_school_assigned do
      school
    end
  end
end
