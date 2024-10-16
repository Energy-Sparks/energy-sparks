FactoryBot.define do
  factory :amr_data_feed_config do
    source_type                   { :email }
    sequence(:identifier)         { |n| "data-config-#{n}" }
    sequence(:description)        { |n| "Data config #{n}" }
    number_of_header_rows         { 1 }
    mpan_mprn_field               { 'MPRN' }
    reading_date_field            { 'Date' }
    date_format                   { '%Y-%m-%d' }
    header_example                do
      'Name,MPAN,Date,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,
14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'
    end
    reading_fields do
      '00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,
14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'.split(',')
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
  end
end
