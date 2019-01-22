FactoryBot.define do
  factory :gas_meter, class: 'Meter'do
    school
    sequence(:mpan_mprn) { |n| n }
    meter_type :gas
    active { true }

    factory :gas_meter_with_reading do
      transient do
        reading_count 1
        config { create(:amr_data_feed_config) }
      end

      after(:create) do |meter, evaluator|
        create_list(:amr_data_feed_reading, evaluator.reading_count, meter: meter, amr_data_feed_config: evaluator.config)
      end
    end

    factory :gas_meter_with_validated_reading do
      transient do
        reading_count 1
      end

      after(:create) do |meter, evaluator|
        create_list(:amr_validated_reading, evaluator.reading_count, meter: meter)
      end
    end
  end

  factory :electricity_meter, class: 'Meter' do
    school
    sequence(:mpan_mprn) { |n| "10#{sprintf('%011d', n)}" }
    meter_type :electricity
    active { true }

    factory :electricity_meter_with_reading do
      transient do
        reading_count 1
        config { create(:amr_data_feed_config) }
      end

      after(:create) do |meter, evaluator|
        create_list(:amr_data_feed_reading, evaluator.reading_count, meter: meter, amr_data_feed_config: evaluator.config)
      end
    end

    factory :electricity_meter_with_validated_reading do
      transient do
        reading_count 1
      end

      after(:create) do |meter, evaluator|
        create_list(:amr_validated_reading, evaluator.reading_count, meter: meter)
      end
    end

    factory :electricity_meter_with_validated_reading_dates do
      transient do
        start_date { Date.yesterday }
        end_date   { Date.today }
      end

      after(:create) do |meter, evaluator|
        (evaluator.start_date..evaluator.end_date).each do |this_date|
          create(:amr_validated_reading, meter: meter, reading_date: this_date)
        end
      end
    end
  end
end

