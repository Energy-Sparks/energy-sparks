# frozen_string_literal: true

FactoryBot.define do
  factory :impact_report_metric, class: 'ImpactReport::Metric' do
    impact_report_run
    metric_category { :energy_efficiency }
    metric_type { :total_saving }
    enough_data { false }
    fuel_type { :electricity }
    value { {} }
  end
end
