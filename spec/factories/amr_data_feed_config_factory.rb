# frozen_string_literal: true

FactoryBot.define do
  factory :amr_data_feed_config do
    source_type                   { :email }
    sequence(:identifier)         { |n| "data-config-#{n}" }
    sequence(:description)        { |n| "Data config #{n}" }
    number_of_header_rows         { 1 }
    mpan_mprn_field               { 'MPRN' }
    reading_date_field            { 'Date' }
    date_format                   { '%Y-%m-%d' }
    # 00:00, 00:30, etc
    reading_fields { Array.new(48) { |i| TimeOfDay.time_of_day_from_halfhour_index(i).to_s } }

    header_example do
      (['Name', mpan_mprn_field, reading_date_field] + reading_fields).join(',')
    end

    trait :with_row_per_reading do
      row_per_reading { true }
      header_example { 'MPRN,Date,KWH' }
      reading_fields { ['KWH'] }
    end

    trait :with_positional_index do
      with_row_per_reading
      positional_index { true }
      period_field { 'Period' }
      header_example { 'MPRN,Date,Period,KWH' }
    end

    trait :with_reading_time_field do
      with_row_per_reading
      positional_index { true }
      reading_time_field { 'Time' }
      header_example { 'MPRN,Date,Time,KWH' }
    end

    trait :with_serial_number_lookup do
      mpan_mprn_field { '' }
      msn_field { 'MSN' }
      lookup_by_serial_number { true }
    end

    trait :with_single_status_field do
      reading_status_fields { ['Estimated'] }
      header_example do
        (['Name', mpan_mprn_field, reading_date_field] + reading_status_fields + reading_fields).join(',')
      end
    end

    trait :with_half_hourly_status_fields do
      reading_status_fields do
        Array.new(48) do |hh|
          "#{TimeOfDay.time_of_day_from_halfhour_index(hh)} Status"
        end
      end
      # MPRN, Date, 00:00, 00:00 Status, 00:30, 00:30 Status, etc
      header_example do
        (['Name', mpan_mprn_field, reading_date_field] + reading_fields.zip(reading_status_fields).flatten).join(',')
      end
    end
  end
end
