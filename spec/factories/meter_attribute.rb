FactoryBot.define do
  factory :meter_attribute do
    attribute_type { :function_switch }
    input_data { 'heating_only' }
    association :meter, factory: :gas_meter
  end
end
