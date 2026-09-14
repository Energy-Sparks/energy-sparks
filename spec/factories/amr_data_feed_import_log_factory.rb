FactoryBot.define do
  factory :amr_data_feed_import_log do
    amr_data_feed_config
    sequence(:file_name)  { |n| "import-#{n}.csv" }
    import_time           { 1.day.ago }
    records_imported      { rand(100) }
    records_updated { rand(100) }

    trait :with_errors do
      error_messages { 'oh no!' }
    end

    trait :with_warnings do
      transient do
        types { AmrReadingWarning::WARNINGS.keys.sample(1) }
      end

      after(:create) do |amr_data_feed_import_log, evaluator|
        create(:amr_reading_warning, amr_data_feed_import_log:, warning_types: evaluator.types)
      end
    end
  end
end
