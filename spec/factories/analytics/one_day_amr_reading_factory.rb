# frozen_string_literal: true

FactoryBot.define do
  factory :one_day_amr_reading, class: 'OneDayAMRReading' do
    transient do
      sequence(:meter_id)   { |n| n }
      date                  { Date.today }
      type                  { 'ORIG' }
      substitute_date       { nil }
      upload_datetime       { DateTime.now }
      kwh_data_x48          { Array.new(48) { rand(0.0..1.0).round(2) } }
    end

    initialize_with do
      new(meter_id, date, type, substitute_date,
          upload_datetime, kwh_data_x48)
    end
  end
end
