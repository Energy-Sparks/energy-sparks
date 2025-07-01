# frozen_string_literal: true

require 'rails_helper'

describe AMRData do
  describe '#baseload_calculator' do
    let(:amr_data)            { build(:amr_data, :with_date_range) }
    let(:overnight)           { false }

    let(:baseload_calculator) { amr_data.send(:baseload_calculator, overnight) }

    it 'returns a statistical calculator' do
      expect(baseload_calculator).to be_a Baseload::StatisticalBaseloadCalculator
    end

    context 'when overnight calculator requested' do
      let(:overnight) { true }

      it 'returns the calculator' do
        expect(baseload_calculator).to be_a Baseload::AroundMidnightBaseloadCalculator
      end
    end

    context 'when calculators are requested twice' do
      it 'returns the same instance' do
        statistical_baseload_calculator = amr_data.send(:baseload_calculator, false)
        expect(amr_data.send(:baseload_calculator, false)).to be statistical_baseload_calculator

        overnight_baseload_calculator = amr_data.send(:baseload_calculator, true)
        expect(amr_data.send(:baseload_calculator, true)).to be overnight_baseload_calculator

        expect(statistical_baseload_calculator).not_to be overnight_baseload_calculator
      end
    end
  end
end
