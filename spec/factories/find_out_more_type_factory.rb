FactoryBot.define do
  factory :find_out_more_type do
    alert_type
    rating_from { 0 }
    rating_to { 10 }
    description { 'This covers all scenarios' }
  end
end
