FactoryBot.define do
  factory :alert_type_rating do
    alert_type
    rating_from { 0 }
    rating_to { 10 }
    description { 'This covers all scenarios' }
  end
end
