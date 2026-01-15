FactoryBot.define do
  factory :secr_co2_equivalence do
    year { Date.current.year }
    electricity_co2e { 0.2 }
    electricity_co2e_co2 { 0.2 }
    transmission_distribution_co2e { 0.02 }
    natural_gas_co2e { 0.2 }
    natural_gas_co2e_co2 { 0.2 }
  end
end
