FactoryBot.define do
  factory :intervention_type do
    sequence(:name) {|n| "Intervention type #{n}"}
    intervention_type_group
    score { 30 }
    sequence(:summary)                  {|n| "Intervention type summary #{n}"}
    sequence(:description)              {|n| "Intervention type description #{n}"}
    sequence(:download_links)           {|n| "Intervention type download links #{n}"}
  end
end
