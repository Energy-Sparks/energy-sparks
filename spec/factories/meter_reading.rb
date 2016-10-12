FactoryGirl.define do
  factory :meter_reading do
    meter
    read_at Date.yesterday
    value { rand }
    unit "kWh"
  end
end
