# frozen_string_literal: true

require 'rails_helper'

describe AlertHolidayAndTermElectricityComparison do
  subject(:alert) { described_class.new(meter_collection) }

  let(:meter_collection) do
    build(:meter_collection, :with_fuel_and_aggregate_meters,
          fuel_type: :electricity,
          holidays: build(:holidays, :with_calendar_year, year: 2023),
          start_date: Date.new(2023, 1, 1),
          end_date: Date.new(2023, 12, 31))
  end

  describe '#analyse' do
    it_behaves_like 'a holiday and term comparison' do
      let(:fuel_type) { :electricity }
      let(:expected_previous_period_start) { Date.new(2023, 7, 16) }
      let(:expected_previous_period_end) { Date.new(2023, 7, 21) }
    end
  end
end
