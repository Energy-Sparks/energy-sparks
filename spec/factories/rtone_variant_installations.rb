FactoryBot.define do
  factory :rtone_variant_installation do
    school
    amr_data_feed_config
    association :meter, factory: :electricity_meter

    sequence(:username) { |n| "username_#{n}" }
    sequence(:password) { |n| "password_#{n}" }
    sequence(:rtone_meter_id) { |n| n }
    rtone_component_type { 1 }
  end
end
