FactoryBot.define do
  factory :configuration, class: Schools::Configuration do
    analysis_charts {{ main_dashboard_electric: { name: "Main page", charts: [:chart_1] } }}
  end
end
