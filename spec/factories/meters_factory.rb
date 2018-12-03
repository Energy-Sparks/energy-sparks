FactoryBot.define do
  factory :gas_meter, class: 'Meter'do
    school
    sequence(:mpan_mprn) { |n| n }
    meter_type :gas
    active { true }

    factory :gas_meter_with_reading do
      transient do
        reading_count 1
      end

      after(:create) do |meter, evaluator|
        create_list(:amr_data_feed_reading, evaluator.reading_count, meter: meter)
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
      end

      after(:create) do |meter, evaluator|
        create_list(:amr_data_feed_reading, evaluator.reading_count, meter: meter)
      end
    end

    factory :electricity__meter_with_validated_reading do
      transient do
        reading_count 1
      end

      after(:create) do |meter, evaluator|
        create_list(:amr_validated_reading, evaluator.reading_count, meter: meter)
      end
    end
  end


end

