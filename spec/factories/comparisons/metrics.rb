FactoryBot.define do
  factory :metric, class: 'Comparison::Metric' do
    school { create(:school) }
    alert_type { create(:alert_type) }
    association :metric_type, factory: :metric_type
    value { 2 }
    association :custom_period, factory: :period
    association :custom_previous_period, factory: :period
    enough_data { true }
    whole_period { true }
    recent_data { true}
    asof_date { Time.zone.today }
  end
end
