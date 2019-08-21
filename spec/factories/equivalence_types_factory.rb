FactoryBot.define do
  factory :equivalence_type do
    meter_type  { EquivalenceType.meter_types.keys.sample }
    time_period { EquivalenceType.time_periods.keys.sample }
    image_name  { EquivalenceType.image_names.keys.first }
  end
end
