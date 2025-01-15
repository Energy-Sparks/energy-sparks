# frozen_string_literal: true

FactoryBot.define do
  factory :solis_cloud_installation do
    school
    amr_data_feed_config
    api_secret { 'secret' }
  end
end
