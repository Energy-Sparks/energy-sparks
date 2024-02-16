FactoryBot.define do
  factory :report_definition, class: 'Comparison::ReportDefinition' do
    transient do
      metric_type_keys { [] }
      order_key { [] }
      schools { [] }
      report_key { nil }
      alert_types { nil }
      fuel_types { nil }
      advice_page { nil }
      order { :desc }
    end

    initialize_with do
      Comparison::ReportDefinition.new(
        metric_type_keys: metric_type_keys,
        order_key: order_key,
        schools: schools,
        report_key: report_key,
        alert_types: alert_types,
        fuel_types: fuel_types,
        advice_page: advice_page,
        order: order
      )
    end
  end
end
