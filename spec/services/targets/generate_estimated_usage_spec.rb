require 'rails_helper'

describe Targets::GenerateEstimatedUsage, type: :service do
  let!(:school)             { create(:school) }
  let!(:aggregated_school)  { double('meter-collection') }

  let!(:service)            { Targets::GenerateEstimatedUsage.new(school, aggregated_school) }

  before do
    school.configuration.update!(fuel_configuration: fuel_configuration)
  end

  describe '#generate' do
    context 'with all fuel types' do
      let(:fuel_configuration) do
        Schools::FuelConfiguration.new(
          has_storage_heaters: true, has_gas: true, has_electricity: true)
      end

      before do
        allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate_kwh).and_return(99)
      end

      it 'lists all estimates' do
        data = service.generate
        expect(data[:electricity]).to eq 99
        expect(data[:gas]).to eq 99
        expect(data[:storage_heater]).to eq 99
      end
    end

    context 'with only electricity' do
      let(:fuel_configuration) do
        Schools::FuelConfiguration.new(
          has_electricity: true)
      end

      before do
        allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate_kwh).and_return(99)
      end

      it 'lists all estimates' do
        data = service.generate
        expect(data[:electricity]).to eq 99
        expect(data[:gas]).to be_nil
        expect(data[:storage_heater]).to be_nil
      end
    end
  end
end
