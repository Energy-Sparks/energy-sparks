FactoryBot.define do
  factory :metric_type, class: 'Comparison::MetricType' do
    sequence(:label) {|n| "Label #{n}"}
    sequence(:key) {|n| "key#{n}"}
    description {|n| "Description #{n}"}
    units { :relative_percent }
    fuel_type { :electricity }
  end
end
