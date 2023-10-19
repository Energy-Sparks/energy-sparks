FactoryBot.define do
  factory :intervention_type_group do
    sequence(:name) {|n| "Intervention type group #{n}"}
    description { "Description" }
  end
end
