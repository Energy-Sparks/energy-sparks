FactoryBot.define do
  factory :staff_role do
    trait :management do
      sequence(:title) {|n| "Management#{n}"}
      dashboard { :management }
    end

    trait :teacher do
      sequence(:title) {|n| "Teacher#{n}"}
      dashboard { :teachers }
    end

  end
end
