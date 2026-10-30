# frozen_string_literal: true

require 'rails_helper'

describe AlertHolidayAndTermGasComparison do
  subject(:alert) { described_class.new(meter_collection) }

  let(:meter_collection) do
    temperatures = build(:temperatures, :with_summer_and_winter, start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))

    meter_collection = build(:meter_collection,
                             holidays: build(:holidays, :with_calendar_year, year: 2023),
                             temperatures: temperatures,
                             start_date: Date.new(2023, 1, 1),
                             end_date: Date.new(2023, 12, 31))

    amr_data = build(:amr_data, :with_summer_and_winter_usage,
                     type: :gas,
                     start_date: Date.new(2023, 1, 1),
                     end_date: Date.new(2023, 12, 31))

    meter = build(:meter, :with_flat_rate_tariffs,
                  meter_collection: meter_collection,
                  type: :gas,
                  amr_data: amr_data)
    meter_collection.add_heat_meter(meter)
    AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters

    meter_collection
  end

  describe '#analyse' do
    it_behaves_like 'a holiday and term comparison' do
      let(:fuel_type) { :gas }
      let(:expected_previous_period_start) { Date.new(2023, 7, 16) }
      let(:expected_previous_period_end) { Date.new(2023, 7, 21) }
      let(:expected_previous_period_multiplier) { 2.0 }
      # with_summer_and_winter_usage trait creates summer usage as 3.0 kWh every 48 HH period by default
      # the shared examples automatically doubles the consumption in the previous period by
      # the provided multipler
      #
      # So expected is 3.0 * 2.0 * 48
      let(:expected_previous_period_average_kwh) { 3.0 * expected_previous_period_multiplier * 48.0 }
      # ...current value will be the unadjusted summer_kwh, so just 3.0 * 48
      let(:current_period_average_kwh) { 3.0 * 48.0 }
    end
  end
end
