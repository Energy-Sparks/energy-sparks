require 'rails_helper'

describe Targets::GenerateEstimatedUsage, type: :service do
  let!(:school)             { create(:school) }
  let!(:aggregated_school)  { double('meter-collection') }

  let!(:service)            { Targets::GenerateEstimatedUsage.new(school, aggregated_school) }

  before do
    school.configuration.update!(fuel_configuration: fuel_configuration)
  end

  describe '#generate' do
    let(:data) { service.generate }

    before do
      allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate_kwh).and_return(99)
    end

    context 'with school that has all fuel types' do
      let(:fuel_configuration) do
        Schools::FuelConfiguration.new(
          has_storage_heaters: true, has_gas: true, has_electricity: true)
      end

      context 'and estimates are required for all' do
        before do
          school.configuration.update!(suggest_estimates_fuel_types: %w(electricity gas storage_heater))
        end

        it 'produces all estimates' do
          expect(data[:electricity]).to eq 99
          expect(data[:gas]).to eq 99
          expect(data[:storage_heater]).to eq 99
        end
      end

      context 'and estimates suggested for gas only' do
        before do
          school.configuration.update!(suggest_estimates_fuel_types: ["gas"])
        end

        it 'produces an estimate for gas only' do
          expect(data[:electricity]).to be_nil
          expect(data[:gas]).to eq 99
          expect(data[:storage_heater]).to be_nil
        end
      end

      it 'does not produce estimates unless needed' do
        expect(data[:electricity]).to be_nil
        expect(data[:gas]).to be_nil
        expect(data[:storage_heater]).to be_nil
      end
    end

    context 'with only electricity' do
      let(:fuel_configuration) do
        Schools::FuelConfiguration.new(
          has_electricity: true)
      end

      context 'and estimates are required' do
        before do
          school.configuration.update!(suggest_estimates_fuel_types: ["electricity"])
        end

        it 'produces estimate for electricity' do
          expect(data[:electricity]).to eq 99
          expect(data[:gas]).to be_nil
          expect(data[:storage_heater]).to be_nil
        end
      end

      it 'does not produce estimates by default' do
        data = service.generate
        expect(data[:electricity]).to be_nil
        expect(data[:gas]).to be_nil
        expect(data[:storage_heater]).to be_nil
      end
    end
  end
end
