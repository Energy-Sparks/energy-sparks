FactoryBot.define do
  factory :gas_meter, class: 'Meter' do
    school
    sequence(:mpan_mprn) { |n| n }
    sequence(:name, 'Meter AAAAA1')
    meter_type            { :gas }
    active                { true }
    meter_system          { :nhh_amr }

    trait :with_unvalidated_readings do
      transient do
        reading_count { 1 }
        config        { create(:amr_data_feed_config) }
        end_date      { Date.parse('01/06/2019') }
        start_date    { end_date - (reading_count - 1).days }
        log           { create(:amr_data_feed_import_log, amr_data_feed_config: config) }
      end

      after(:create) do |meter, evaluator|
        (evaluator.start_date.to_date..evaluator.end_date.to_date).each do |this_date|
          create(:amr_data_feed_reading, meter: meter, reading_date: this_date.strftime('%b %e %Y %I:%M%p'), amr_data_feed_config: evaluator.config, amr_data_feed_import_log: evaluator.log)
        end
      end
    end

    factory :gas_meter_with_reading do
      with_unvalidated_readings
    end

    factory :gas_meter_with_validated_reading do
      transient do
        reading_count { 1 }
      end

      after(:create) do |meter, evaluator|
        create_list(:amr_validated_reading, evaluator.reading_count, meter: meter)
      end
    end

    factory :gas_meter_with_validated_reading_dates do
      transient do
        start_date      { Date.parse('01/06/2019') }
        end_date        { Date.parse('02/06/2019') }
        status          { 'ORIG' }
        reading         { nil }
        kwh_data_x48    { Array.new(48, reading || rand) }
        one_day_kwh     { 139.0 }
        upload_datetime { Time.zone.today }
        substitute_date { nil }
      end

      after(:create) do |meter, evaluator|
        (evaluator.start_date.to_date..evaluator.end_date.to_date).each do |this_date|
          create(:amr_validated_reading,
            meter: meter,
            reading_date: this_date,
            upload_datetime: evaluator.upload_datetime,
            status: evaluator.status,
            kwh_data_x48: evaluator.kwh_data_x48,
            one_day_kwh: evaluator.one_day_kwh,
            substitute_date: evaluator.substitute_date)
        end
      end
    end
  end

  factory :electricity_meter, class: 'Meter' do
    school
    sequence(:mpan_mprn) { |n| "10#{sprintf('%011d', n)}" }
    sequence(:name, 'Meter AAAAA1')
    meter_type            { :electricity }
    active                { true }
    meter_system          { :nhh_amr }

    factory :electricity_meter_with_reading do
      transient do
        reading_count { 1 }
        config        { create(:amr_data_feed_config) }
        readings      { Array.new(48, rand) }
        reading_date_format { '%b %e %Y %I:%M%p' }
      end

      after(:create) do |meter, evaluator|
        end_date = Date.parse('01/06/2019')
        start_date = end_date - (evaluator.reading_count - 1).days
        (start_date..end_date).each do |this_date|
          create(:amr_data_feed_reading, meter: meter, reading_date: this_date.strftime(evaluator.reading_date_format),
                                         readings: evaluator.readings, amr_data_feed_config: evaluator.config)
        end
      end
    end

    factory :electricity_meter_with_validated_reading do
      transient do
        reading_count { 1 }
      end

      after(:create) do |meter, evaluator|
        create_list(:amr_validated_reading, evaluator.reading_count, meter: meter)
      end
    end

    factory :electricity_meter_with_validated_reading_dates do
      transient do
        start_date { Date.parse('01/06/2019') }
        end_date   { Date.parse('02/06/2019') }
        reading    { nil }
      end

      after(:create) do |meter, evaluator|
        (evaluator.start_date.to_date..evaluator.end_date.to_date).each do |this_date|
          create(:amr_validated_reading, meter: meter, reading_date: this_date, reading: evaluator.reading)
        end
      end
    end
  end

  factory :exported_solar_pv_meter, class: 'Meter' do
    school
    sequence(:mpan_mprn)  { |n| "91#{sprintf('%012d', n)}" }
    meter_type            { :exported_solar_pv }
    active                { true }
    meter_system          { :nhh_amr }

    trait :with_unvalidated_readings do
      transient do
        reading_count { 1 }
        config        { create(:amr_data_feed_config) }
        end_date      { Date.parse('01/06/2019') }
        start_date    { end_date - (reading_count - 1).days }
        import_log    { create(:amr_data_feed_import_log, amr_data_feed_config: config) }
      end

      after(:create) do |meter, evaluator|
        (evaluator.start_date.to_date..evaluator.end_date.to_date).each do |this_date|
          create(:amr_data_feed_reading, meter: meter, reading_date: this_date.strftime('%b %e %Y %I:%M%p'), amr_data_feed_config: evaluator.config, amr_data_feed_import_log: evaluator.import_log)
        end
      end
    end
  end

  factory :solar_pv_meter, class: 'Meter' do
    school
    sequence(:mpan_mprn) { |n| "71#{sprintf('%012d', n)}" }
    sequence(:name, 'Meter AAAAA1')
    meter_type            { :solar_pv }
    active                { true }
    meter_system          { :nhh_amr }

    trait :with_unvalidated_readings do
      transient do
        reading_count { 1 }
        config        { create(:amr_data_feed_config) }
        end_date      { Date.parse('01/06/2019') }
        start_date    { end_date - (reading_count - 1).days }
        log           { create(:amr_data_feed_import_log, amr_data_feed_config: config) }
      end

      after(:create) do |meter, evaluator|
        (evaluator.start_date.to_date..evaluator.end_date.to_date).each do |this_date|
          create(:amr_data_feed_reading, meter: meter, reading_date: this_date.strftime('%b %e %Y %I:%M%p'), amr_data_feed_config: evaluator.config, amr_data_feed_import_log: evaluator.log)
        end
      end
    end
  end
end
