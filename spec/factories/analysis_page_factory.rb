FactoryBot.define do
  factory :analysis_page do
    association :content_generation_run
    association :content_version, factory: :alert_type_rating_content_version
    alert
  end
end
