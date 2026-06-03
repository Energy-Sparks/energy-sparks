# frozen_string_literal: true

require 'rails_helper'

describe Baseload::AroundMidnightBaseloadCalculator, type: :service do
  subject(:calculator)  { described_class.new(amr_data) }

  let(:start_date)      { Date.new(2023, 1, 1) }
  let(:end_date)        { Date.new(2023, 1, 2) }
  let(:kwh_data_x48)    { Array.new(48, 0.1) }
  let(:amr_data)        do
    build(:amr_data, :with_date_range, start_date: start_date, end_date: end_date, kwh_data_x48: kwh_data_x48)
  end

  describe '#baseload_kw' do
    let(:day)             { start_date }
    let(:baseload_kw)     { calculator.baseload_kw(day) }

    it 'calculates the baseload for a day' do
      expect(baseload_kw).to be_within(0.0000001).of(0.2)
    end

    context 'when there is varied consumption over the day' do
      # first 2 and last 2 hours are 0.1, rest are random
      let(:kwh_data_x48) { Array.new(4, 0.1) + Array.new(40, rand(1.1..3.0)) + Array.new(4, 0.1) }

      it 'calculates the baseload using periods before and after midnight' do
        expect(baseload_kw).to be_within(0.0000001).of(0.2)
      end
    end

    context 'when the day is not in the data' do
      let(:day)  { Date.new(2023, 4, 1) }

      it 'raises an exception' do
        expect { baseload_kw }.to raise_error(EnergySparksNotEnoughDataException)
      end
    end
  end
end
