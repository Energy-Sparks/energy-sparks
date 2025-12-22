# frozen_string_literal: true

FactoryBot.define do
  factory :meter_collection, class: 'MeterCollection' do
    transient do
      start_date              { Date.yesterday - 7 }
      end_date                { Date.yesterday }
      school                  { build(:analytics_school) }
      holidays                { build(:holidays, :with_calendar_year) }
      random_generator        { nil }
      temperatures            { build(:temperatures, :with_days, start_date:, end_date:, random_generator:) }
      solar_pv                { build(:solar_pv, :with_days, start_date:, end_date:, random_generator:) }
      grid_carbon_intensity   { build(:grid_carbon_intensity, :with_days, start_date:, end_date:, random_generator:) }
      pseudo_meter_attributes { {} }
      solar_irradiation       { nil }
    end

    initialize_with do
      new(school,
          holidays: holidays, temperatures: temperatures,
          solar_irradiation: solar_irradiation, solar_pv: solar_pv,
          grid_carbon_intensity: grid_carbon_intensity,
          pseudo_meter_attributes: pseudo_meter_attributes)
    end

    # Unvalidated/unaggregated meter collection with a single electricity meter
    trait :with_electricity_meter do
      transient do
        kwh_data_x48 { nil }
        dcc_meter { false }
      end

      after(:build) do |meter_collection, evaluator|
        amr_data = build(:amr_data, :with_date_range, start_date: evaluator.start_date, end_date: evaluator.end_date,
                                                      kwh_data_x48: evaluator.kwh_data_x48)
        meter = build(:meter, :with_flat_rate_tariffs, meter_collection: meter_collection,
                                                       type: :electricity,
                                                       amr_data: amr_data,
                                                       tariff_start_date: evaluator.start_date,
                                                       tariff_end_date: evaluator.end_date,
                                                       dcc_meter: evaluator.dcc_meter)
        meter_collection.add_electricity_meter(meter)
      end
    end

    # Unvalidated/unaggregated meter collection with a single gas meter
    trait :with_gas_meter do
      after(:build) do |meter_collection, evaluator|
        amr_data = build(:amr_data, :with_date_range, start_date: evaluator.start_date, end_date: evaluator.end_date)
        meter = build(:meter, :with_flat_rate_tariffs, meter_collection: meter_collection, type: :gas,
                                                       amr_data: amr_data, tariff_start_date: evaluator.start_date,
                                                       tariff_end_date: evaluator.end_date)
        meter_collection.add_heat_meter(meter)
      end
    end

    # Unvalidated/unaggregated meter collection with one gas and one electricity meter
    trait :with_electricity_and_gas_meters do
      with_electricity_meter
      with_gas_meter
    end

    # Unvalidated/unaggregated meter collection with multiple electricity meters
    trait :with_electricity_meters do
      transient do
        meters { [] }
      end
      after(:build) do |meter_collection, evaluator|
        evaluator.meters.each do |m|
          meter_collection.add_electricity_meter(m)
        end
      end
    end

    # Meter collection with an aggregate meter of configurable fuel type
    # Does not invoke the normal validation/aggregation process
    trait :with_aggregate_meter do
      transient do
        fuel_type { :electricity }
        kwh_data_x48 { nil }
      end
      after(:build) do |meter_collection, evaluator|
        amr_data = build(:amr_data, :with_date_range, start_date: evaluator.start_date, end_date: evaluator.end_date,
                                                      kwh_data_x48: evaluator.kwh_data_x48)
        meter = build(:meter, meter_collection: meter_collection, type: evaluator.fuel_type, amr_data: amr_data)
        meter_collection.set_aggregate_meter(evaluator.fuel_type, meter)
      end
    end

    # Meter collection with an aggregate meter of configurable fuel type, with configurable sub_meter relationships
    # Does not invoke the normal validation/aggregation process
    trait :with_sub_meters do
      with_aggregate_meter

      transient do
        sub_meters { {} }
      end
      after(:build) do |meter_collection, evaluator|
        aggregate_meter = meter_collection.aggregate_meter(evaluator.fuel_type)
        aggregate_meter.sub_meters.merge!(evaluator.sub_meters)
      end
    end

    # Meter collection with a single meter, of configurable fuel type.
    # Invokes the validation and aggregation process
    trait :with_aggregated_aggregate_meter do
      transient do
        fuel_type { :electricity }
        storage_heaters { false }
        kwh_data_x48 { Array.new(48, 1) }
        rates { nil }
      end
      with_aggregate_meter

      after(:build) do |meter_collection, evaluator|
        meter_attributes = {}
        if evaluator.storage_heaters
          meter_attributes[:storage_heaters] = [{ charge_start_time: TimeOfDay.parse('02:00'),
                                                  charge_end_time: TimeOfDay.parse('06:00') }]
          # match charge times, increases usage just enough for model to consider heating on
          evaluator.kwh_data_x48[4, 10] = [4] * 10
        end
        meter = build(:meter, :with_flat_rate_tariffs,
                      meter_collection: meter_collection, type: evaluator.fuel_type,
                      meter_attributes: meter_attributes,
                      amr_data: build(:amr_data, :with_date_range,
                                      type: evaluator.fuel_type,
                                      start_date: evaluator.start_date,
                                      end_date: evaluator.end_date,
                                      kwh_data_x48: evaluator.kwh_data_x48),
                      rates: evaluator.rates)
        meter_collection.send(evaluator.fuel_type == :electricity ? :add_electricity_meter : :add_heat_meter, meter)
        AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
      end
    end
  end
end
