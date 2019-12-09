require 'dashboard'

FactoryBot.define do
  factory :dashboard_one_day_amr_reading, class: 'OneDayAMRReading' do
    transient do
      association :dashboard_meter, factory: :dashboard_gas_meter
      date          { Date.yesterday }
      kwh_data_x48  { Array.new(48, rand.to_f) }
      one_day_kwh   { kwh_data_x48.sum.to_f }
      status        { 'ORIG'}
    end

    # Note the nil is the substitute date
    initialize_with { OneDayAMRReading.new(dashboard_meter.id, date, status, nil, DateTime.now, kwh_data_x48) }
  end
end
