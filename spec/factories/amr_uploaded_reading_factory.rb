FactoryBot.define do
  factory :amr_uploaded_reading do
    amr_data_feed_config         { create(:amr_data_feed_config) }
    sequence(:file_name)         { |n| "file_name-#{n}.csv" }
    imported                     { false }
  end
end
