FactoryBot.define do
  factory :reports, class: 'Comparison::Report' do
    reporting_period { :last_12_months }
    association :custom_period, factory: :period
    enough_data { true }
    whole_period { true }
    recent_data { true}
    asof_date { Time.zone.today }
  end
end
