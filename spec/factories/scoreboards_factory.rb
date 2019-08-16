FactoryBot.define do
  factory :scoreboard do
    sequence(:name) {|n| "Scoreboard #{n}"}
    calendar_area
  end
end
