FactoryBot.define do
  factory :comparison_metric_type do
    key { 'activationyear_electricity_kwh_relative_percent' }
    label { 'Activation year electricity in kWh' }
    description { 'Activation year electricity in kWh' }
    units { :relative_percent }
    fuel_type { :electricity }
  end
end
