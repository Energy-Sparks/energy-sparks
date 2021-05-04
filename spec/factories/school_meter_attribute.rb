FactoryBot.define do
  factory :school_meter_attribute do
    attribute_type { :function_switch }
    input_data { 'heating_only' }
    association :school, factory: :school
    meter_types { ["gas", "electricity"] }
  end
end
