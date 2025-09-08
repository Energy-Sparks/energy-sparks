# frozen_string_literal: true

FactoryBot.define do
  factory :grid_carbon_intensity, class: 'GridCarbonIntensity' do
    initialize_with { new }

    trait :with_days do
      transient do
        start_date { Date.yesterday - 7 }
        end_date { Date.yesterday }
        kwh_data_x48 { Array.new(48) { rand(0.2..0.3).round(3) } }
      end

      after(:build) do |gci, evaluator|
        (evaluator.start_date..evaluator.end_date).each do |date|
          gci.add(date, evaluator.kwh_data_x48)
        end
      end
    end
  end
end
