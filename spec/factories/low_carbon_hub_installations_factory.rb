FactoryBot.define do
  factory :low_carbon_hub_installation do
    school
    sequence(:rbee_meter_id, (100_000..900_000).cycle) { |n| n }
    amr_data_feed_config

    username { |n| "username_#{n}" }
    password { |n| "password_#{n}" }

    factory :low_carbon_hub_installation_with_meters_and_validated_readings do
      transient do
        reading_count { 1 }
        config        { create(:amr_data_feed_config) }
      end

      after(:create) do |low_carbon_hub_installation, _evaluator|
        electricity_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 60_000_000_000_000 + low_carbon_hub_installation.rbee_meter_id.to_i, pseudo: true, low_carbon_hub_installation: low_carbon_hub_installation)
        solar_pv_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 70_000_000_000_000 + low_carbon_hub_installation.rbee_meter_id.to_i, pseudo: true, low_carbon_hub_installation: low_carbon_hub_installation)
        solar_pv_meter.update(meter_type: :solar_pv)
        export_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 90_000_000_000_000 + low_carbon_hub_installation.rbee_meter_id.to_i, pseudo: true, low_carbon_hub_installation: low_carbon_hub_installation)
        export_meter.update(meter_type: :exported_solar_pv)
      end
    end
  end
end
