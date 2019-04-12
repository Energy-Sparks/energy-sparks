FactoryBot.define do
  factory :find_out_more do
    association :calculation, factory: :find_out_more_calculation
    association :content_version, factory: :alert_type_rating_content_version
    alert
  end
end
