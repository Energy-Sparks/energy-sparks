FactoryBot.define do
  factory :activity_category do
    sequence(:name)         {|n| "Category#{n}"}
    sequence(:description)  {|n| "Description#{n}"}
  end
end
