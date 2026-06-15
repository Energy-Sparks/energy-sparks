FactoryBot.define do
  factory :funder do
    sequence(:name) {|n| "Funder name #{n}"}
  end
end
