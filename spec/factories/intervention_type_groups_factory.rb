FactoryBot.define do
  factory :intervention_type_group do
    sequence(:title) {|n| "Intervention type group #{n}"}
    description      { "Description" }
  end
end
