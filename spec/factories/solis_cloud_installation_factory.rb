# frozen_string_literal: true

FactoryBot.define do
  factory :solis_cloud_installation do
    amr_data_feed_config
    api_id { 'id' }
    api_secret { 'secret' }
  end
end
