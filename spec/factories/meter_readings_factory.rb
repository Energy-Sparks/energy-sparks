FactoryBot.define do
  factory :meter_reading do
    association :meter, factory: :gas_meter
    read_at Date.yesterday
    value { rand }
    unit "kWh"
  end
end
