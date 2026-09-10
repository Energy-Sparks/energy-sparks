FactoryBot.define do
  factory :amr_data_feed_reading do
    reading_date  { Date.yesterday.strftime('%b %e %Y %I:%M%p') }
    parsed_date { Date.yesterday }
    readings      { Array.new(48, rand) }
    association :meter, factory: :gas_meter
    mpan_mprn { Random.new.rand(240000000000000)}
    amr_data_feed_import_log
    amr_data_feed_config
  end
end
