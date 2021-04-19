FactoryBot.define do
  factory :tariff_price do
    association :meter, factory: :electricity_meter
    sequence(:tariff_date) { |n| Date.today - n.days }
    association :tariff_import_log, factory: :tariff_import_log

    trait :with_flat_rate do
      transient do
        flat_rate   { Array.new(48, 0.3) }
      end

      after(:create) do |tariff_prices, evaluator|
          tariff_prices.update(prices: evaluator.flat_rate)
      end
    end

    trait :with_tiered_tariff do
      transient do
        tiered_rate   { Array.new(10, 0.1) + Array.new(20, 0.2) + Array.new(18, 0.3) }
      end

      after(:create) do |tariff_prices, evaluator|
          tariff_prices.update(prices: evaluator.tiered_rate)
      end

    end

    trait :with_differential_tiered_tariff do
      transient do
        tiered_rate   { [{:tariffs=>{1=>0.45, 2=>0.2}, :thresholds=>{1=>1000}, :type=>:tiered}] + Array.new(47, 0.1) }
      end

      after(:create) do |tariff_prices, evaluator|
          tariff_prices.update(prices: evaluator.tiered_rate)
      end

    end

  end
end
