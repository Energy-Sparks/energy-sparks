# frozen_string_literal: true

require 'spec_helper'

describe AlertConfigurablePeriodGasComparison, :aggregate_failures do
  subject(:alert) do
    meter_collection = build(:meter_collection, :with_fuel_and_aggregate_meters,
                             start_date: Date.new(2022, 11, 1), end_date: Date.new(2023, 11, 30),
                             fuel_type: :gas, random_generator: Random.new(22))
    configuration = {
      name: 'Layer up power down day 24 November 2023',
      max_days_out_of_date: 365,
      enough_days_data: 1,
      current_period: Date.new(2023, 11, 24)..Date.new(2023, 11, 24),
      previous_period: Date.new(2023, 11, 17)..Date.new(2023, 11, 17)
    }
    alert = described_class.new(meter_collection)
    alert.comparison_configuration = configuration
    alert
  end

  describe '#analyse' do
    it 'runs and sets variables' do
      alert.analyse(Date.new(2023, 11, 30))
      expect(alert.previous_period_kwh).to be_within(0.01).of(48)
      expect(alert.current_period_kwh).to be_within(0.01).of(48)
    end
  end
end
