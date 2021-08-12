FactoryBot.define do
  factory :management_dashboard_table do
    content_generation_run
    content_version { create(:alert_type_rating_content_version) }
    alert
  end
end
