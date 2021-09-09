FactoryBot.define do
  factory :intervention_type  do
    sequence(:title) {|n| "Intervention type #{n}"}
    intervention_type_group
    points { 30 }
    summary { "Summary" }
  end
end
