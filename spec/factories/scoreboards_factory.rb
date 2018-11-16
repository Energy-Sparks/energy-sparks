FactoryBot.define do
  factory :scoreboard do
    sequence(:name) {|n| "Scoreboard #{n}"}
  end
end
