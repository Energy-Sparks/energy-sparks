FactoryBot.define do
  factory :rtone_variant_installation do
    school
    amr_data_feed_config
    association :meter, factory: :electricity_meter

    username { |n| "username_#{n}" }
    password { |n| "password_#{n}" }

    sequence(:rtone_meter_id, (100000..900000).cycle)  { |n| n }
    rtone_meter_type { 1 }
  end
end
