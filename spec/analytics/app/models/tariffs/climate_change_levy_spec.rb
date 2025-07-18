# frozen_string_literal: true

require 'rails_helper'

describe ClimateChangeLevy do
  describe '.rate' do
    let(:fuel_type) { :electricity }
    let(:rate) { ClimateChangeLevy.rate(fuel_type, date) }

    context 'with missing configuration' do
      let(:date) { Date.new(2050, 1, 1) }

      it 'throws an exception' do
        expect { rate }.to raise_error ClimateChangeLevy::MissingClimateChangeLevyData
      end
    end

    context 'with earlier data' do
      let(:date) { Date.new(2017, 10, 1) }

      it 'returns zero' do
        expect(rate).to eq([:climate_change_levy, 0.0])
      end
    end

    context 'when data is valid' do
      context 'with electricity' do
        let(:date) { Date.new(2023, 10, 1) }

        it 'returns expected value' do
          expect(rate).to eq([:climate_change_levy, 0.00775])
        end
      end

      context 'with gas' do
        let(:fuel_type) { :gas }
        let(:date) { Date.new(2021, 6, 1) }

        it 'returns expected value' do
          expect(rate).to eq([:climate_change_levy, 0.00465])
        end
      end
    end
  end
end
