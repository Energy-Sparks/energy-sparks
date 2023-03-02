FactoryBot.define do
  factory :advice_page do
    sequence(:key)        {|n| "Advice Page #{n}"}
    sequence(:learn_more) {|n| "Learn more #{n}"}
    restricted  { false }
    fuel_type { "electricity" }
  end
end
