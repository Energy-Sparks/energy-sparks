# frozen_string_literal: true

FactoryBot.define do
  factory :amr_reading_warning do
    amr_data_feed_import_log
    warning_types { AmrReadingData::WARNINGS.keys.sample(1) }
  end
end
