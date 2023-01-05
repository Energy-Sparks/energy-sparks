FactoryBot.define do
  factory :advice_page do
    sequence(:key)  {|n| "Advice Page #{n}"}
  end
end
