FactoryBot.define do
  factory :school_target do
    school
    start_date { Time.zone.today.beginning_of_month }
    target_date { Time.zone.today.beginning_of_month.next_year }
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
          'fuel_type': 'electricity',
          'months': ['2024-01-01'],
          'monthly_targets_kwh': [],
          'monthly_usage_kwh': [],
          'monthly_performance': [],
          'cumulative_targets_kwh': [],
          'cumulative_usage_kwh': [],
          'cumulative_performance': [],
          'cumulative_performance_versus_synthetic_last_year': [],
          'monthly_performance_versus_synthetic_last_year': [],
          'partial_months': [],
          'percentage_synthetic': []
        }
        target["#{evaluator.fuel_type}_report"] = report
        target
      end
    end
  end
end
