FactoryBot.define do
  factory :amr_data_feed_import_log do
    amr_data_feed_config
    sequence(:file_name)  { |n| "import-#{n}.csv" }
    import_time           { 1.day.ago }
    records_imported      { rand(100) }
  end
end
