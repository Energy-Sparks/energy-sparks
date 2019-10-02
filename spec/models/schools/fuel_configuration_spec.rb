require 'rails_helper'


describe Schools::FuelConfiguration do

  it 'converts fuel_types_for_analysis to a symbol' do
    expect(Schools::FuelConfiguration.new(fuel_types_for_analysis: 'gas_only').fuel_types_for_analysis).to eq(:gas_only)
  end

  describe '#dual_fuel' do

    it 'is true if the school is gas and electricity' do
      expect(Schools::FuelConfiguration.new(has_gas: true, has_electricity: true, fuel_types_for_analysis: :x).dual_fuel).to eq(true)
    end

    it 'is false if the school is missing either' do
      expect(Schools::FuelConfiguration.new(has_gas: false, has_electricity: true, fuel_types_for_analysis: :x).dual_fuel).to eq(false)
      expect(Schools::FuelConfiguration.new(has_gas: true, has_electricity: false, fuel_types_for_analysis: :x).dual_fuel).to eq(false)
      expect(Schools::FuelConfiguration.new(has_gas: false, has_electricity: false, fuel_types_for_analysis: :x).dual_fuel).to eq(false)
    end
  end

  describe '#no_meters_with_validated_readings?' do
    it 'is false if the school is gas or electricity' do
      expect(Schools::FuelConfiguration.new(has_gas: false, has_electricity: true, fuel_types_for_analysis: :x).no_meters_with_validated_readings).to eq(false)
      expect(Schools::FuelConfiguration.new(has_gas: true, has_electricity: false, fuel_types_for_analysis: :x).no_meters_with_validated_readings).to eq(false)
      expect(Schools::FuelConfiguration.new(has_gas: true, has_electricity: true, fuel_types_for_analysis: :x).no_meters_with_validated_readings).to eq(false)
    end
    it 'is true if the school is missing both' do
      expect(Schools::FuelConfiguration.new(has_gas: false, has_electricity: false, fuel_types_for_analysis: :x).no_meters_with_validated_readings).to eq(true)
    end
  end


end
