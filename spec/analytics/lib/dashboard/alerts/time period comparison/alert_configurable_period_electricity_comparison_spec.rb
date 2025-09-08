# frozen_string_literal: true

require 'rails_helper'

describe AlertConfigurablePeriodElectricityComparison do
  subject(:alert) do
    meter_collection = build(:meter_collection, :with_fuel_and_aggregate_meters,
                             start_date: Date.new(2022, 11, 1), end_date: Date.new(2023, 11, 30))
    alert = described_class.new(meter_collection)
    alert.comparison_configuration = configuration
    alert
  end

  let(:configuration) do
    {
      name: 'Layer up power down day 24 November 2023',
      max_days_out_of_date: 365,
      enough_days_data: 1,
      current_period: Date.new(2023, 11, 24)..Date.new(2023, 11, 24),
      previous_period: Date.new(2023, 11, 17)..Date.new(2023, 11, 17)
    }
  end

  before { travel_to(Date.new(2023, 12, 31)) }

  describe '#timescale' do
    it { expect(alert.timescale).to eq('custom') }
  end

  describe '#analyse' do
    it 'runs and sets variables' do
      expect(alert.valid_alert?).to be true
      alert.analyse(Date.new(2023, 11, 30))
      expect(alert.analysis_date).to eq(Date.new(2023, 11, 30))
      expect(alert.current_period_kwh).to be_within(0.01).of(48)
      expect(alert.current_period_start_date).to eq(Date.new(2023, 11, 24))
      expect(alert.current_period_end_date).to eq(Date.new(2023, 11, 24))
      expect(alert.name_of_current_period).to eq(configuration[:name])
      expect(alert.previous_period_kwh).to be_within(0.01).of(48)
      expect(alert.previous_period_start_date).to eq(Date.new(2023, 11, 17))
      expect(alert.previous_period_end_date).to eq(Date.new(2023, 11, 17))
      expect(alert.name_of_previous_period).to eq(configuration[:name])
    end

    it 'errors with not enough days of data' do
      configuration[:enough_days_data] = 1000
      alert.analyse(Date.new(2023, 11, 30))
      expect(alert.error_message).to start_with('Not enough data in current period: ')
    end

    it 'does not run when max_days_out_of_date' do
      configuration[:max_days_out_of_date] = 1
      alert.analyse(Date.new(2023, 12, 5))
      expect(alert.analysis_date).to be_nil
    end
  end
end
