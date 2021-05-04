FactoryBot.define do
  factory :global_meter_attribute do
    attribute_type { :function_switch }
    input_data { 'heating_only' }
    meter_types { ["gas", "electricity"] }
  end
end
