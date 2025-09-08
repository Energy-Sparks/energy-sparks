# frozen_string_literal: true

FactoryBot.define do
  factory :temperatures, class: 'Temperatures' do
    transient do
      type { 'temperatures' }
      random_generator { nil }
    end

    initialize_with { new(type) }

    trait :with_days do
      transient do
        start_date { Date.yesterday - 7 }
        end_date { Date.yesterday }
        kwh_data_x48 { Array.new(48) { (random_generator || Random.new).rand.round(2) } }
      end

      after(:build) do |temperatures, evaluator|
        (evaluator.start_date..evaluator.end_date).each do |date|
          temperatures.add(date, evaluator.kwh_data_x48)
        end
      end
    end

    trait :with_summer_and_winter do
      transient do
        start_date { Date.yesterday - 7 }
        end_date { Date.yesterday }
        summer_months { [6, 7, 8] }
        summer_temp { Array.new(48) { 20.0 } }
        winter_temp { Array.new(48) { 1.0 } }
      end

      after(:build) do |temperatures, evaluator|
        (evaluator.start_date..evaluator.end_date).each do |date|
          temps = evaluator.summer_months.include?(date.month) ? evaluator.summer_temp : evaluator.winter_temp
          temperatures.add(date, temps)
        end
      end
    end
  end
end
