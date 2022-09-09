FactoryBot.define do
  factory :alert_subscription_event do
    # association :content_generation_run
    association :content_version, factory: :alert_type_rating_content_version
    alert
  end
end
