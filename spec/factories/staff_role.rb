FactoryBot.define do
  factory :staff_role do
    trait :management do
      title { 'Management' }
    end

    trait :teacher do
      title { 'Teacher' }
    end
  end
end
