FactoryBot.define do
  factory :activity_category do
    sequence(:name) {|n| "Category#{n}"}
  end
end
