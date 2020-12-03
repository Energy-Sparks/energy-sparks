FactoryBot.define do
  factory :solar_edge_installation do

    school
    sequence(:site_id, (100000..900000).cycle)  { |n| n }
    amr_data_feed_config

    # factory :low_carbon_hub_installation_with_meters_and_validated_readings do
    #
    #   transient do
    #     reading_count { 1 }
    #     config        { create(:amr_data_feed_config) }
    #   end
    #
    #   after(:create) do |low_carbon_hub_installation, evaluator|
    #     electricity_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 60000000000000 + low_carbon_hub_installation.rbee_meter_id.to_i, pseudo: true, low_carbon_hub_installation: low_carbon_hub_installation)
    #     solar_pv_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 70000000000000 + low_carbon_hub_installation.rbee_meter_id.to_i, pseudo: true, low_carbon_hub_installation: low_carbon_hub_installation)
    #     solar_pv_meter.update(meter_type: :solar_pv)
    #     export_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 90000000000000 + low_carbon_hub_installation.rbee_meter_id.to_i, pseudo: true, low_carbon_hub_installation: low_carbon_hub_installation)
    #     export_meter.update(meter_type: :exported_solar_pv)
    #   end
    # end
  end
end

