# frozen_string_literal: true

require 'rails_helper'

describe AlertConfigurablePeriodGasComparison, :aggregate_failures do
  subject(:alert) do
    school = build(:analytics_school)
    meter_collection = build(:meter_collection, :with_aggregated_aggregate_meter,
                             start_date: Date.new(2022, 11, 1), end_date: Date.new(2023, 11, 30),
                             fuel_type: :gas, random_generator: Random.new(22), school:,
                             pseudo_meter_attributes: { school_level_data: {
                               floor_area_pupil_numbers: [{ start_date: Date.new(2023, 11, 17),
                                                            end_date: Date.new(2023, 11, 17),
                                                            floor_area: school.floor_area / 2 }]
                             } })
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
      alert.analyse(Date.new(2023, 11, 30))
      expect(alert.previous_period_kwh).to be_within(0.01).of(96)
      expect(alert.current_period_kwh).to be_within(0.01).of(48)
      expect(alert.name_of_current_period).to eq(configuration[:name])
      expect(alert.name_of_previous_period).to eq(configuration[:name])
    end

    it 'can disable normalisation' do
      configuration[:disable_normalisation] = true
      alert.analyse(Date.new(2023, 11, 30))
      expect(alert.previous_period_kwh).to be_within(0.01).of(48)
      expect(alert.current_period_kwh).to be_within(0.01).of(48)
    end
  end
end
