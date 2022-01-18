FactoryBot.define do
  factory :configuration, class: Schools::Configuration do
    analysis_charts {{ main_dashboard_electric: { name: "Main page", charts: [:chart_1] } }}
    fuel_configuration { Schools::FuelConfiguration.new }
    school_target_fuel_types { [] }
  end
end
