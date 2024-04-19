require 'rails_helper'

class DummyMultipleFuelComparisonView < OpenStruct
  include MultipleFuelComparisonView
end

describe MultipleFuelComparisonView do
  subject(:model) do
    DummyMultipleFuelComparisonView.new(
      electricity_previous_period_kwh: 1.0,
      electricity_current_period_kwh: 2.0,
      electricity_previous_period_co2: 2.5,
      electricity_current_period_co2: 5.0,
      electricity_previous_period_gbp: 3.0,
      electricity_current_period_gbp: 6.0,
      gas_previous_period_kwh: 10.0,
      gas_current_period_kwh: 20.0,
      gas_previous_period_co2: 25.0,
      gas_current_period_co2: 50.0,
      gas_previous_period_gbp: 30.0,
      gas_current_period_gbp: 60.0,
      storage_heater_previous_period_kwh: 100.0,
      storage_heater_current_period_kwh: 200.0,
      storage_heater_previous_period_co2: 250.0,
      storage_heater_current_period_co2: 500.0,
      storage_heater_previous_period_gbp: 300.0,
      storage_heater_current_period_gbp: 600.0
    )
  end

  describe '#field_names' do
    it 'returns all expected attributes' do
      expect(model.field_names(period: :previous_period)).to match_array([:electricity_previous_period_kwh, :gas_previous_period_kwh, :storage_heater_previous_period_kwh])
      expect(model.field_names(period: :current_period)).to match_array([:electricity_current_period_kwh, :gas_current_period_kwh, :storage_heater_current_period_kwh])
      expect(model.field_names(period: :current_period, unit: :co2)).to match_array([:electricity_current_period_co2, :gas_current_period_co2, :storage_heater_current_period_co2])
      expect(model.field_names(period: :current_period, unit: :£)).to match_array([:electricity_current_period_gbp, :gas_current_period_gbp, :storage_heater_current_period_gbp])
    end

    describe 'with customised_fuel_types' do
      subject(:model) do
        DummyMultipleFuelComparisonView.new(
          electricity_previous_period_kwh: 1.0,
          electricity_current_period_kwh: 2.0,
          electricity_previous_period_co2: 2.5,
          electricity_current_period_co2: 5.0,
          electricity_previous_period_gbp: 3.0,
          electricity_current_period_gbp: 6.0,
          gas_previous_period_kwh: 10.0,
          gas_current_period_kwh: 20.0,
          gas_previous_period_co2: 25.0,
          gas_current_period_co2: 50.0,
          gas_previous_period_gbp: 30.0,
          gas_current_period_gbp: 60.0,
          fuel_types: [:electricity, :gas]
        )
      end

      it 'returns all expected attributes' do
        expect(model.field_names(period: :previous_period)).to match_array([:electricity_previous_period_kwh, :gas_previous_period_kwh])
        expect(model.field_names(period: :current_period)).to match_array([:electricity_current_period_kwh, :gas_current_period_kwh])
        expect(model.field_names(period: :current_period, unit: :co2)).to match_array([:electricity_current_period_co2, :gas_current_period_co2])
        expect(model.field_names(period: :current_period, unit: :£)).to match_array([:electricity_current_period_gbp, :gas_current_period_gbp])
      end
    end
  end

  describe '#total_current_period' do
    it 'returns expected values' do
      expect(model.total_current_period).to eq(222.0)
      expect(model.total_current_period(unit: :co2)).to eq(555.0)
      expect(model.total_current_period(unit: :£)).to eq(666.0)
    end
  end

  describe '#all_previous_period' do
    it 'returns expected values' do
      expect(model.all_previous_period).to match_array([1.0, 10.0, 100.0])
      expect(model.all_previous_period(unit: :co2)).to match_array([2.5, 25.0, 250.0])
      expect(model.all_previous_period(unit: :£)).to match_array([3.0, 30.0, 300.0])
    end
  end
end
