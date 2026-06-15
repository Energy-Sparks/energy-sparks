FactoryBot.define do
  factory :calendar_area do
    sequence(:title) { |n| "Calendar area #{n}" }
  end

  trait :child do
    parent_area { create(:calendar_area, :parent) }
  end

  trait :parent do
    after(:create) do |calendar_area, _evaluator|
      create(:academic_year, calendar_area: calendar_area)
    end
  end
end
