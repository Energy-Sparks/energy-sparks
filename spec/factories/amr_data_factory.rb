# frozen_string_literal: true

FactoryBot.define do
  factory :amr_data, class: 'AMRData' do
    transient do
      type { :electricity }
    end

    initialize_with { new(type) }

    trait :single_day do
      after(:build) do |data|
        data.add(Time.zone.today, build(:one_day_amr_reading))
      end
    end

    trait :with_date_range do
      transient do
        start_date   { Date.yesterday - 7 }
        end_date     { Date.yesterday }
        kwh_data_x48 { nil }
      end

      after(:build) do |amr_data, evaluator|
        (evaluator.start_date..evaluator.end_date).each do |date|
          reading = build(:one_day_amr_reading,
                          date: date,
                          type: 'ORIG',
                          substitute_date: nil,
                          upload_datetime: DateTime.now,
                          kwh_data_x48: (evaluator.kwh_data_x48 || Array.new(48) { rand.round(2) }).dup)
          amr_data.add(date, reading)
        end
      end
    end

    trait :with_days do
      transient do
        day_count { 7 }
        end_date { Time.zone.today }
        kwh_data_x48 { nil }
      end

      after(:build) do |amr_data, evaluator|
        evaluator.day_count.times do |n|
          date = evaluator.end_date - n
          kwargs = {}
          kwargs[:kwh_data_x48] = evaluator.kwh_data_x48.dup unless evaluator.kwh_data_x48.nil?
          amr_data.add(date, build(:one_day_amr_reading, date:, **kwargs))
        end
      end
    end

    trait :with_grid_carbon_intensity do
      transient do
        start_date            { Date.yesterday - 7 }
        end_date              { Date.yesterday }
        meter_id              { 1234 }
        flat_rate             { nil }
        grid_carbon_intensity { nil }
      end

      after(:build) do |amr_data, evaluator|
        carbon_intensity = if evaluator.grid_carbon_intensity.nil?
                             build(:grid_carbon_intensity, start_date: evaluator.start_date,
                                                           end_date: evaluator.end_date)
                           else
                             evaluator.grid_carbon_intensity
                           end
        amr_data.set_carbon_emissions(evaluator.meter_id, evaluator.flat_rate, carbon_intensity)
      end
    end

    trait :with_summer_and_winter_usage do
      transient do
        start_date   { Date.yesterday - 7 }
        end_date     { Date.yesterday }
        summer_months { [6, 7, 8] }
        summer_kwh   { Array.new(48, 3.0) }
        winter_kwh   { Array.new(48, 30.0) }
      end

      after(:build) do |amr_data, evaluator|
        (evaluator.start_date..evaluator.end_date).each do |date|
          kwh_data_x48 = evaluator.summer_months.include?(date.month) ? evaluator.summer_kwh : evaluator.winter_kwh
          reading = build(:one_day_amr_reading,
                          date: date,
                          type: 'ORIG',
                          substitute_date: nil,
                          upload_datetime: DateTime.now,
                          kwh_data_x48: kwh_data_x48)
          amr_data.add(date, reading)
        end
      end
    end
  end
end
