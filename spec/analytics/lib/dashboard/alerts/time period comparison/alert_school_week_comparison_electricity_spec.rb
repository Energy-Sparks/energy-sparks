# frozen_string_literal: true

require 'rails_helper'

describe AlertSchoolWeekComparisonElectricity do
  subject(:alert) { described_class.new(meter_collection) }

  let(:meter_collection) do
    temperatures = build(:temperatures, :with_summer_and_winter, start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))

    meter_collection = build(:meter_collection,
                             holidays: build(:holidays, :with_calendar_year, year: 2023),
                             temperatures: temperatures,
                             start_date: Date.new(2023, 1, 1),
                             end_date: Date.new(2023, 12, 31))

    amr_data = build(:amr_data, :with_summer_and_winter_usage,
                     type: :electricity,
                     start_date: Date.new(2023, 1, 1),
                     end_date: Date.new(2023, 12, 31))

    meter = build(:meter, :with_flat_rate_tariffs,
                  meter_collection: meter_collection,
                  type: :electricity,
                  amr_data: amr_data)
    meter_collection.add_electricity_meter(meter)
    AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters

    meter_collection
  end

  let(:analysis_date) { Date.new(2023, 10, 15) } # few weeks into autum term

  around do |example|
    travel_to analysis_date do
      example.run
    end
  end

  describe '#analyse' do
    before do
      alert.analyse(analysis_date)
    end

    it 'uses the right periods' do
      expect(alert.previous_period_start_date).to eq(Date.new(2023, 10, 1))
      expect(alert.previous_period_end_date).to eq(Date.new(2023, 10, 7))

      expect(alert.current_period_start_date).to eq(Date.new(2023, 10, 8))
      expect(alert.current_period_end_date).to eq(Date.new(2023, 10, 14))

      expect(alert.truncated_current_period).to be(false)
    end

    it_behaves_like 'a valid alert', date: Date.new(2023, 10, 15)
  end
end
