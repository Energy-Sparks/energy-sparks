FactoryBot.define do
  factory :solar_edge_installation do
    school
    amr_data_feed_config
    sequence(:site_id, (100000..900000).cycle) { |n| n }
    sequence(:mpan) { |n| n }

    sequence(:api_key) { |n| "api_key_#{n}" }
    information do
      { site_detail: '', dates: %w(2023-01-01 2023-10-01) }
    end

    sequence(:access_token, 'SolarEdgeAccessTokenAAAAA1')
    sequence(:refresh_token, 'SolarEdgeRefreshTokenAAAAA1')
    consent_granted_at { 4.hours.ago }
    access_token_expires_at { Time.now.utc + 2.hours }

    trait :unconsented do
      refresh_token { nil }
      access_token { nil }
      consent_granted_at { nil }
    end

    trait :with_expired_access_token do
      access_token_expires_at { Time.now.utc - 5.seconds }
    end

    trait :with_electricity_meter do
      after(:create) do |solar_edge_installation, _evaluator|
        create(:electricity_meter,
          mpan_mprn: 60000000000000 + solar_edge_installation.mpan.to_i,
          pseudo: true,
          solar_edge_installation: solar_edge_installation)
      end
    end

    factory :solar_edge_installation_with_meters_and_validated_readings do
      transient do
        reading_count { 1 }
        config        { create(:amr_data_feed_config, process_type: :solar_edge_api, source_type: :api) }
      end

      after(:create) do |solar_edge_installation, _evaluator|
        create(:electricity_meter_with_validated_reading, mpan_mprn: 60000000000000 + solar_edge_installation.mpan.to_i, pseudo: true, solar_edge_installation: solar_edge_installation)
        solar_pv_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 70000000000000 + solar_edge_installation.mpan.to_i, pseudo: true, solar_edge_installation: solar_edge_installation)
        solar_pv_meter.update(meter_type: :solar_pv)
        export_meter = create(:electricity_meter_with_validated_reading, mpan_mprn: 90000000000000 + solar_edge_installation.mpan.to_i, pseudo: true, solar_edge_installation: solar_edge_installation)
        export_meter.update(meter_type: :exported_solar_pv)
      end
    end
  end
end
