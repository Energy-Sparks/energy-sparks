FactoryBot.define do
  factory :rtone_variant_installation do
    school
    amr_data_feed_config
    association :meter, factory: :electricity_meter

    username { |n| "username_#{n}" }
    password { |n| "password_#{n}" }

    sequence(:rtone_meter_id, (100_000..900_000).cycle) { |n| n }
    rtone_component_type { 1 }
  end
end
