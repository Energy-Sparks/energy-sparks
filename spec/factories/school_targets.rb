# frozen_string_literal: true

FactoryBot.define do
  factory :school_target do
    school
    start_date { Time.zone.today.beginning_of_month }
    target_date { start_date.next_year }
    electricity { rand(1..10) }
    gas { rand(1..10) }
    storage_heaters { rand(1..10) }
    report_last_generated { DateTime.now }
    electricity_progress { {} }
    gas_progress { {} }
    storage_heaters_progress { {} }

    trait :with_progress_report do
      transient do
        fuel_type { :electricity }
      end

      after(:build) do |target, evaluator|
        report = {
          fuel_type: evaluator.fuel_type.to_s,
          months: ['2024-01-01'],
          monthly_targets_kwh: [],
          monthly_usage_kwh: [],
          monthly_performance: [],
          cumulative_targets_kwh: [],
          cumulative_usage_kwh: [],
          cumulative_performance: [],
          cumulative_performance_versus_synthetic_last_year: [],
          monthly_performance_versus_synthetic_last_year: [],
          partial_months: [],
          percentage_synthetic: []
        }
        target["#{evaluator.fuel_type}_report"] = report
        target
      end
    end

    trait :with_monthly_consumption do
      transient do
        fuel_type { :electricity }
        target { 4 }
        missing { false }
        current_consumption { 1010 }
        previous_consumption { 1020 }
        target_consumption { 1000 }
      end

      after(:build) do |target, evaluator|
        target[evaluator.fuel_type] = evaluator.target
        target["#{evaluator.fuel_type}_monthly_consumption"] = (0..11).map do |i|
          month = target.start_date.month - 1 + i
          [target.start_date.year + (month / 12), (month % 12) + 1, evaluator.current_consumption,
           evaluator.previous_consumption, evaluator.target_consumption, evaluator.missing]
        end
      end
    end
  end
end
