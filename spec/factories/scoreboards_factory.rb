FactoryBot.define do
  factory :scoreboard do
    sequence(:name) {|n| "Scoreboard #{n}"}
    calendar_area { create(:calendar_area, :parent) }
  end
end
