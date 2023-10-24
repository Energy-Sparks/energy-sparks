FactoryBot.define do
  factory :energy_tariff_charge do
    energy_tariff
    charge_type { :standing_charge }
    units       { :day }
    value       { 1.0 }
  end
end
