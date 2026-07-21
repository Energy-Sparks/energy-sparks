# frozen_string_literal: true

FactoryBot.define do
  factory :meter_z_installation do
    amr_data_feed_config
    api_key { 'key' }
    meters_list do
      [{ 'organisation_id' => 'organisation_id',
         'site_id' => 'site_id',
         'meter_id' => 'meter_id' }]
    end
  end
end
