FactoryBot.define do
  factory :intervention_type do
    sequence(:name, 'Intervention Type AAAA1')
    intervention_type_group
    score { 30 }
    sequence(:summary)                  {|n| "Intervention type summary #{n}"}
    sequence(:description)              {|n| "Intervention type description #{n}"}
    sequence(:download_links)           {|n| "Intervention type download links #{n}"}
  end
end
