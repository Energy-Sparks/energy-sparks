FactoryBot.define do
  factory :staff_role do
    trait :management do
      sequence(:title) {|n| "Management#{n}"}
    end

    trait :teacher do
      sequence(:title) {|n| "Teacher#{n}"}
    end

  end
end
