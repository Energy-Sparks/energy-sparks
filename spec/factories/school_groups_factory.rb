FactoryBot.define do
  factory :school_group do
    sequence(:name) { |n| "School group #{n}" }
  end
end
