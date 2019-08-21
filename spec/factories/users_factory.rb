FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@test.com" }
    password         { 'testpass' }

    factory :pupil do
      role { :pupil }
      pupil_password { 'test' }
    end

    trait :has_school_assigned do
      school
    end
  end
end
