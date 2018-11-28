FactoryBot.define do
  factory :amr_validated_reading do
    association :meter, factory: :gas_meter
    reading_date Date.yesterday
    kwh_data_x48 { Array.new(48, rand) }
    one_day_kwh { 139.0 }
    status { 'ORIG'}
  end
end
