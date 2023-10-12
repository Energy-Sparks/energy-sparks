require 'dashboard'

FactoryBot.define do
  factory :dashboard_one_day_amr_reading, class: 'OneDayAMRReading' do
    transient do
      association :dashboard_meter, factory: :dashboard_gas_meter
      date            { Date.yesterday }
      status          { 'ORIG' }
      substitute_date { nil }
      upload_datetime { Time.zone.today }
      kwh_data_x48    { Array.new(48, rand.to_f) }
    end

    initialize_with { OneDayAMRReading.new(dashboard_meter.id, date, status, substitute_date, upload_datetime, kwh_data_x48) }
  end
end
