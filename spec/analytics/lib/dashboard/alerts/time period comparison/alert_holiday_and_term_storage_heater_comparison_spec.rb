# frozen_string_literal: true

require 'rails_helper'

describe AlertHolidayAndTermStorageHeaterComparison do
  subject(:alert) { described_class.new(meter_collection) }

  let(:meter_collection) do
    temperatures = build(:temperatures, :with_summer_and_winter, start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))

    meter_collection = build(:meter_collection,
                             holidays: build(:holidays, :with_calendar_year, year: 2023),
                             temperatures: temperatures,
                             start_date: Date.new(2023, 1, 1),
                             end_date: Date.new(2023, 12, 31))

    # Fake up storage heater being on between 2am-6am all year round
    amr_data = build(:amr_data, :with_date_range,
                     type: :gas,
                     start_date: Date.new(2023, 1, 1),
                     end_date: Date.new(2023, 12, 31),
                     kwh_data_x48: Array.new(4, 3.0) + Array.new(9, 33.0) + Array.new(35, 3.0))

    meter_attributes = {
      storage_heaters: [
        { charge_start_time: TimeOfDay.parse('02:00'),
          charge_end_time: TimeOfDay.parse('06:00') }
      ]
    }

    meter = build(:meter, :with_flat_rate_tariffs,
                  meter_collection: meter_collection,
                  meter_attributes: meter_attributes,
                  type: :electricity,
                  amr_data: amr_data)
    meter_collection.add_electricity_meter(meter)
    AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters

    meter_collection
  end

  describe '#analyse' do
    it_behaves_like 'a holiday and term comparison' do
      let(:fuel_type) { :storage_heater }
      let(:expected_previous_period_start) { Date.new(2023, 7, 16) }
      let(:expected_previous_period_end) { Date.new(2023, 7, 21) }
      let(:expected_previous_period_multiplier) { 2.0 }
      # The amr_data created above has 30 kWh associated with storage heaters for
      # the 9 half-hourly periods between 2am-6am. This is all allocated as heating
      # So the current period is 9 * 3.0
      let(:current_period_average_kwh) { 9 * 30.0 }
      # ...and then doubled for previous period
      let(:expected_previous_period_average_kwh) { 9.0 * 30 * expected_previous_period_multiplier }
    end
  end
end
