FactoryBot.define do
  factory :metric_type do
    key { 'activationyear_electricity_kwh' }
    label { 'Activation year electricity kwh' }
    description { 'Activation year electricity in kwh' }
    type { :kwh }
    fuel_type { :electricity }
  end
end
