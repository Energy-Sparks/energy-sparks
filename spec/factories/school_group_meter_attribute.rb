FactoryBot.define do
  factory :school_group_meter_attribute do
    attribute_type { :meter_corrections_switch }
    input_data { 'correct_zero_partial_data' }
    school_group
    meter_types { %w[gas electricity] }
  end
end
