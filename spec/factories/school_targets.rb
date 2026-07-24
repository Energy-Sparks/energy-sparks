# frozen_string_literal: true

FactoryBot.define do
  factory :school_target do
    school
    start_date { Time.zone.today.beginning_of_month }
    target_date { start_date.next_year }
    electricity { rand(1..10) }
    gas { rand(1..10) }
    storage_heaters { rand(1..10) }

    trait :with_monthly_consumption do
      transient do
        consumption { nil }
        fuel_type { :electricity }
        target { 4 }
        current_missing { false }
        previous_missing { false }
        current_consumption { 1010 }
        previous_consumption { 1020 }
        target_consumption { 1000 }
        manual { false }
      end

      after(:build) do |target, evaluator|
        (evaluator.consumption.nil? ? [evaluator.fuel_type] : evaluator.consumption).each do |fuel_type, consumption|
          target[fuel_type] = evaluator.target
          target["#{fuel_type}_monthly_consumption"] = (0..11).map do |i|
            month = target.start_date + i.months
            [month.year, month.month,
             *%i[current_consumption previous_consumption target_consumption current_missing previous_missing manual]
               .freeze.map do |name|
               value = consumption&.[](name) ? consumption[name] : evaluator.public_send(name)
               value.is_a?(Enumerable) ? value[i] : value
             end]
          end
        end
      end
    end
  end
end
