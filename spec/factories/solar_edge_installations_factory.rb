FactoryBot.define do
  factory :solar_edge_installation do
    school
    sequence(:site_id, (100_000..900_000).cycle) { |n| n }
    amr_data_feed_config
    sequence(:mpan) { |n| n }
    sequence(:api_key) { |n| "api_key_#{n}" }

    factory :solar_edge_installation_with_meters_and_validated_readings do
      transient do
        reading_count { 1 }
        config        { create(:amr_data_feed_config, process_type: :solar_edge_api) }
      end

      after(:create) do |solar_edge_installation, _evaluator|
        electricity_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 60_000_000_000_000 + solar_edge_installation.mpan.to_i, pseudo: true, solar_edge_installation: solar_edge_installation)
        solar_pv_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 70_000_000_000_000 + solar_edge_installation.mpan.to_i, pseudo: true, solar_edge_installation: solar_edge_installation)
        solar_pv_meter.update(meter_type: :solar_pv)
        export_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 90_000_000_000_000 + solar_edge_installation.mpan.to_i, pseudo: true, solar_edge_installation: solar_edge_installation)
        export_meter.update(meter_type: :exported_solar_pv)
      end
    end
  end
end
