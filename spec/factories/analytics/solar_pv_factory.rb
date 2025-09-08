# frozen_string_literal: true

FactoryBot.define do
  factory :solar_pv, class: 'SolarPV' do
    transient do
      type { 'solar_pv' }
      random_generator { nil }
    end

    initialize_with { new(type) }

    trait :with_days do
      transient do
        start_date { Date.yesterday - 7 }
        end_date { Date.yesterday }
        data_x48 { Array.new(48) { (random_generator || Random.new).rand.round(2) } }
      end

      after(:build) do |solar_pv, evaluator|
        (evaluator.start_date..evaluator.end_date).each do |date|
          solar_pv.add(date, evaluator.data_x48)
        end
      end
    end
  end
end
