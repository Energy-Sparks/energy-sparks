# frozen_string_literal: true

FactoryBot.define do
  factory :solar_edge_installation do
    school
    amr_data_feed_config { association :amr_data_feed_config, :solar_edge_api }

    sequence(:site_id, (100_000..900_000).cycle) { |n| n }
    sequence(:mpan) { |n| n }

    information do
      {
        'site_details' => { 'activationStatus' => 'ACTIVE' },
        'dates' => {
          from: '2023-01-01',
          to: '2023-10-01'
        },
        'inventory' => [
          { 'type' => 'METER', 'active' => true, 'meterType' => 'FeedIn', 'name' => 'Export Meter',
            'serialNumber' => '12345' },
          { 'type' => 'METER', 'active' => true, 'meterType' => 'Purchased', 'name' => 'Import Meter',
            'serialNumber' => '12345' },
          { 'type' => 'METER', 'active' => true, 'meterType' => 'SelfConsumption', 'name' => 'Self Consumption' },
          { 'type' => 'METER', 'active' => true, 'meterType' => 'Consumption', 'name' => 'Consumption Meter' }
        ]
      }
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

    trait :pending_status do
      information do
        {
          'site_details' => { 'activationStatus' => 'PENDING' }
        }
      end
    end

    trait :with_inactive_import_and_export do
      information do
        {
          'site_details' => { 'activationStatus' => 'ACTIVE' },
          'dates' => {
            from: '2023-01-01',
            to: '2023-10-01'
          },
          'inventory' => [
            { 'type' => 'METER', 'active' => false, 'meterType' => 'FeedIn', 'name' => 'Export Meter',
              'serialNumber' => '12345' },
            { 'type' => 'METER', 'active' => false, 'meterType' => 'Purchased', 'name' => 'Import Meter',
              'serialNumber' => '12345' },
            { 'type' => 'METER', 'active' => false, 'meterType' => 'SelfConsumption', 'name' => 'Self Consumption' },
            { 'type' => 'METER', 'active' => false, 'meterType' => 'Consumption', 'name' => 'Consumption Meter' }
          ]
        }
      end
    end

    trait :with_electricity_meter do
      after(:create) do |solar_edge_installation, _evaluator|
        create(:electricity_meter,
               school: solar_edge_installation.school,
               mpan_mprn: 60_000_000_000_000 + solar_edge_installation.mpan.to_i,
               pseudo: true,
               solar_edge_installation:)
      end
    end

    factory :solar_edge_installation_with_meters_and_validated_readings do
      transient do
        reading_count { 1 }
      end

      after(:create) do |solar_edge_installation, _evaluator|
        create(:electricity_meter_with_validated_reading,
               school: solar_edge_installation.school,
               mpan_mprn: 60_000_000_000_000 + solar_edge_installation.mpan.to_i,
               pseudo: true,
               solar_edge_installation:)
        create(:electricity_meter_with_validated_reading,
               meter_type: :solar_pv,
               school: solar_edge_installation.school,
               mpan_mprn: 70_000_000_000_000 + solar_edge_installation.mpan.to_i,
               pseudo: true,
               solar_edge_installation:)
        create(:electricity_meter_with_validated_reading,
               meter_type: :exported_solar_pv,
               school: solar_edge_installation.school,
               mpan_mprn: 90_000_000_000_000 + solar_edge_installation.mpan.to_i,
               pseudo: true,
               solar_edge_installation:)
      end
    end
  end
end
