FactoryBot.define do
  factory :amr_validated_reading do
    association :meter, factory: :gas_meter
    sequence(:reading_date) { |n| Time.zone.today - n.days }
    kwh_data_x48            { Array.new(48, rand) }
    one_day_kwh             { 139.0 }
    status                  { 'ORIG'}
    upload_datetime         { Time.zone.today }
    substitute_date         { nil }
  end
end
