# frozen_string_literal: true

FactoryBot.define do
  factory :meter, class: 'Dashboard::Meter' do
    transient do
      meter_collection        { nil }
      kwh_data_x48            { nil }
      day_count               { 30 }
      amr_data                { build(:amr_data, :with_days, day_count:, kwh_data_x48:) }
      type                    { :gas }
      sequence(:identifier)   { |n| n }
      sequence(:name)         { |n| "Meter #{n}" }
      floor_area              { 0 }
      number_of_pupils        { 1 }
      solar_pv_installation   { nil }
      external_meter_id       { nil }
      dcc_meter               { false }
      meter_attributes        { {} }
    end

    initialize_with do
      new(meter_collection:, amr_data:, type:, identifier:, name:, floor_area:, number_of_pupils:,
          solar_pv_installation:, external_meter_id:, dcc_meter:, meter_attributes:)
    end

    trait :with_flat_rate_tariffs do
      transient do
        rates { create_flat_rate(rate: 0.10, standing_charge: 1.0) }
        tariff_start_date { nil }
        tariff_end_date   { nil }
      end

      initialize_with do
        accounting_tariff = create_accounting_tariff_generic(
          start_date: tariff_start_date,
          end_date: tariff_end_date,
          rates: rates
        )
        new(meter_collection: meter_collection,
            amr_data: amr_data, type: type, identifier: identifier,
            name: name, floor_area: floor_area, number_of_pupils: number_of_pupils,
            solar_pv_installation: solar_pv_installation,
            external_meter_id: external_meter_id,
            dcc_meter: dcc_meter,
            meter_attributes: { accounting_tariff_generic: [accounting_tariff] }.merge(meter_attributes))
      end

      after(:build) do |meter, _evaluator|
        meter.set_tariffs
      end
    end

    trait :with_tariffs do
      transient do
        accounting_tariffs { [] }
      end

      initialize_with do
        meter_attributes = { accounting_tariff_generic: accounting_tariffs }
        new(meter_collection: meter_collection,
            amr_data: amr_data, type: type, identifier: identifier,
            name: name, floor_area: floor_area, number_of_pupils: number_of_pupils,
            solar_pv_installation: solar_pv_installation,
            external_meter_id: external_meter_id,
            dcc_meter: dcc_meter,
            meter_attributes: meter_attributes)
      end

      after(:build) do |meter, _evaluator|
        meter.set_tariffs
      end
    end

    trait :with_storage_heater do
      transient do
        start_date   { Date.yesterday - 7 }
        end_date     { Date.yesterday }
        kwh_data_x48 { Array.new(48, 1.0) }
        charge_start_time { TimeOfDay.parse('02:00') }
        charge_end_time { TimeOfDay.parse('06:00') }
      end

      initialize_with do
        meter_attributes = {}
        meter_attributes[:storage_heaters] = [
          { charge_start_time: charge_start_time,
            charge_end_time: charge_end_time }
        ]

        charge_period = charge_end_time.to_halfhour_index - charge_start_time.to_halfhour_index + 1
        # match charge times, increases usage just enough for model to consider heating on
        kwh_data_x48[charge_start_time.to_halfhour_index..
                     charge_end_time.to_halfhour_index] = [4.0] * charge_period
        amr_data = build(:amr_data,
                         :with_date_range,
                         type: :electricity,
                         start_date: start_date,
                         end_date: end_date,
                         kwh_data_x48: kwh_data_x48)
        build(:meter,
              meter_collection: meter_collection,
              type: :electricity, meter_attributes: meter_attributes,
              amr_data: amr_data)
      end
    end
  end
end
