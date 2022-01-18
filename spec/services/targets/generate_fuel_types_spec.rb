require 'rails_helper'

describe Targets::GenerateFuelTypes do

  let!(:school)             { create(:school) }
  let!(:aggregated_school)  { double('meter-collection') }

  let!(:service)            { Targets::GenerateFuelTypes.new(school, aggregated_school) }

  before(:each) do
    school.configuration.update!(fuel_configuration: fuel_configuration)
  end

  context 'with all fuel types and enough data' do
    let(:fuel_configuration)   { Schools::FuelConfiguration.new(
      has_solar_pv: false, has_storage_heaters: true, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: true) }

    before(:each) do
      allow_any_instance_of(::TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
    end

    it 'lists all types' do
      expect(service.perform).to match_array(["electricity", "gas", "storage_heater"])
    end
  end

  context 'with limited fuel types and enough data' do
    let(:fuel_configuration)   { Schools::FuelConfiguration.new(
      has_solar_pv: false, has_storage_heaters: false, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: false) }

    before(:each) do
      allow_any_instance_of(::TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
    end

    it 'lists just the right types' do
      expect(service.perform).to match_array(["gas"])
    end
  end

  context 'with all fuel types and no data' do
    let(:fuel_configuration)   { Schools::FuelConfiguration.new(
      has_solar_pv: false, has_storage_heaters: true, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: true) }

    before(:each) do
      allow_any_instance_of(::TargetsService).to receive(:enough_data_to_set_target?).and_return(false)
    end

    it 'lists nothing' do
      expect(service.perform).to match_array([])
    end
  end

  context 'with an error' do
    let(:fuel_configuration)   { Schools::FuelConfiguration.new(
      has_solar_pv: false, has_storage_heaters: true, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: true) }

    before(:each) do
      allow_any_instance_of(::TargetsService).to receive(:enough_data_to_set_target?).and_raise("error")
    end

    it 'returns some result' do
      expect(service.perform).to match_array([])
    end
  end
end
