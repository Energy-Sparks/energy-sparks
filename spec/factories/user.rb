FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@test.com" }
    password 'testpass'

    trait :has_school_assigned do
      school
    end
  end
end
