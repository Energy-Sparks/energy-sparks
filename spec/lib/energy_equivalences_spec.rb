# frozen_string_literal: true

require 'rails_helper'

describe EnergyEquivalences do
  describe '#set_co2_kg_kwh' do
    context 'when not the test environment' do
      before do
        create(:secr_co2_equivalence, year: 2025)
        allow(Rails.env).to receive(:test?).and_return(false)
      end

      it 'accesses the database' do
        expect(described_class.send(:set_co2_kg_kwh)).to eq({ electricity: 0.2, gas: 0.2 })
      end
    end
  end
end
