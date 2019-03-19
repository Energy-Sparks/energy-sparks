FactoryBot.define do
  factory :find_out_more do
    association :content_version, factory: :find_out_more_type_content_version
    alert
  end
end
