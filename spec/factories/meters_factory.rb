FactoryBot.define do
  factory :gas_meter, class: 'Meter'do
    school
    sequence(:mpan_mprn)  { |n| n }
    meter_type            { :gas }
    active                { true }

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
        start_date { Date.parse('01/06/2019') }
        end_date   { Date.parse('02/06/2019') }
      end

      after(:create) do |meter, evaluator|
        (evaluator.start_date.to_date..evaluator.end_date.to_date).each do |this_date|
          create(:amr_validated_reading, meter: meter, reading_date: this_date)
        end
      end
    end
  end

  factory :electricity_meter, class: 'Meter' do
    school
    sequence(:mpan_mprn)  { |n| "10#{sprintf('%011d', n)}" }
    meter_type            { :electricity }
    active                { true }

    factory :electricity_meter_with_reading do
      transient do
        reading_count { 1 }
        config        { create(:amr_data_feed_config) }
      end

      after(:create) do |meter, evaluator|
        end_date = Date.parse('01/06/2019')
        start_date = end_date - (evaluator.reading_count - 1).days
        (start_date..end_date).each do |this_date|
          create(:amr_data_feed_reading, meter: meter, reading_date: this_date.strftime('%b %e %Y %I:%M%p'), amr_data_feed_config: evaluator.config)
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
      end

      after(:create) do |meter, evaluator|
        (evaluator.start_date.to_date..evaluator.end_date.to_date).each do |this_date|
          create(:amr_validated_reading, meter: meter, reading_date: this_date)
        end
      end
    end
  end

  factory :exported_solar_pv_meter, class: 'Meter' do
    school
    sequence(:mpan_mprn)  { |n| "60#{sprintf('%011d', n)}" }
    meter_type            { :exported_solar_pv }
    active                { true }

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
