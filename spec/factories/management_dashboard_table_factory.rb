FactoryBot.define do
  factory :management_dashboard_table do
    association :content_generation_run
    association :content_version, factory: :alert_type_rating_content_version
    alert
  end
end
