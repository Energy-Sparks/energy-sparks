FactoryBot.define do
  factory :staff_role do
    trait :management do
      title { 'Business Manager' }
    end

    trait :teacher do
      title { 'Teacher' }
    end
  end
end
