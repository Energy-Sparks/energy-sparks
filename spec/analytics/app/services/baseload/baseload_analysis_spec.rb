# frozen_string_literal: true

require 'rails_helper'

describe Baseload::BaseloadAnalysis do
  subject(:calculator)  { described_class.new(meter) }

  let(:day_count)       { 365 }
  let(:amr_data)        { build(:amr_data, :with_days, day_count: day_count) }
  let(:meter)           { build(:meter, amr_data: amr_data) }

  describe '#one_years_data?' do
    it 'returns true with a years worth of data' do
      expect(calculator.one_years_data?).to be true
    end

    context 'with limited data' do
      let(:day_count)    { 30 }

      it 'returns false' do
        expect(calculator.one_years_data?).to be false
      end
    end

    context 'with historical asof_date' do
      let(:day_count) { 365 * 2 }

      it 'returns true if there is a years worth of data before then' do
        expect(calculator.one_years_data?(Date.today - 365)).to be true
      end

      it 'returns false if not enough data' do
        expect(calculator.one_years_data?(Date.today - 500)).to be false
      end
    end
  end
end
