FactoryBot.define do
  factory :metric_type do
    key { 'activationyear_electricity_kwh_relative_percent' }
    label { 'activationyear electricity in kwh' }
    description { 'Activation year electricity in kwh' }
    units { :relative_percent }
    fuel_type { :electricity }
  end
end
