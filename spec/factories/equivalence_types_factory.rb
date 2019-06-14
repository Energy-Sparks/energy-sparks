FactoryBot.define do
  factory :equivalence_type do
    meter_type  { EquivalenceType.meter_types.keys.sample }
    time_period { EquivalenceType.time_periods.keys.sample }
  end
end
