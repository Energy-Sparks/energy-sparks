# frozen_string_literal: true

FactoryBot.define do
  factory :impact_report_metric, class: 'ImpactReport::Metric' do
    run factory: %i[impact_report_run]
    metric_category { :overview }
    metric_type { :active_users }
    enough_data { true }
    fuel_type { nil }
    value { 9 }
    number_of_schools { 4 }
  end
end
