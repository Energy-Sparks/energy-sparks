FactoryBot.define do
  factory :dashboard_alert do
    dashboard { :teacher }
    association :content_generation_run
    association :content_version, factory: :alert_type_rating_content_version
    alert
  end
end
