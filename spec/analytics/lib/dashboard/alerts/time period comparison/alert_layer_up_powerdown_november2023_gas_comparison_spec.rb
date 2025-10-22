# frozen_string_literal: true

require 'rails_helper'

describe AlertLayerUpPowerdownNovember2023GasComparison do
  subject(:alert) do
    meter_collection = build(:meter_collection, :with_fuel_and_aggregate_meters, random_generator: Random.new(14),
                             fuel_type: :gas, start_date: Date.new(2021, 11, 30), end_date: Date.new(2023, 11, 30))
    described_class.new(meter_collection)
  end

  before { travel_to(Date.new(2023, 12, 31)) }

  describe '#analyse' do
    it 'runs and sets variables' do
      alert.analyse(Date.new(2023, 11, 30))
      expect(alert.previous_period_kwh).to be_within(0.01).of(48)
      expect(alert.current_period_kwh).to be_within(0.01).of(48)
    end
  end
end
