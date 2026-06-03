# frozen_string_literal: true

require 'rails_helper'

describe DateTimeHelper do
  describe '#weighted_x48_vector_multiple_ranges' do
    context 'with single range' do
      let(:range) { [TimeOfDay.new(8, 50)..TimeOfDay.new(15, 20)] }

      it 'returns expected values' do
        vector = described_class.weighted_x48_vector_multiple_ranges(range)
        expect(vector[0..16]).to eq Array.new(17, 0.0)
        # 8.50 means only final 10 minutes, 1/3rd of half hour
        expect(vector[17].round(2)).to eq 0.33
        expect(vector[18..29]).to eq Array.new(12, 1.0)
        # 15,20 means first 20 minutes, so 2/3rd of half hour
        expect(vector[30].round(2)).to eq 0.67
        expect(vector[31..48]).to eq Array.new(17, 0.0)
      end
    end

    context 'with multiple ranges' do
      let(:range) { [TimeOfDay.new(15, 21)..TimeOfDay.new(19, 30), TimeOfDay.new(7, 0)..TimeOfDay.new(8, 49)] }

      it 'returns expected values' do
        vector = described_class.weighted_x48_vector_multiple_ranges(range)
        expect(vector[0..13]).to eq Array.new(14, 0.0)
        # 14 == 7am
        # 16 == 8am
        expect(vector[14..16]).to eq Array.new(3, 1.0)
        # 17 == 8.30am, 19 / 30 minutes (% time through hh slot)
        expect(vector[17]).to eq 0.6333333333333333
        # 19 == 9.00am
        expect(vector[18..29]).to eq Array.new(12, 0.0)
        # 30 == 15.00, 21 / 30 minutes (% time through hh slot)
        expect(vector[30].round(2)).to eq 0.3
        expect(vector[31..38]).to eq Array.new(8, 1.0)
        expect(vector[39..48]).to eq Array.new(9, 0.0)
      end
    end
  end

  describe '#weighted_x48_vector_single_range' do
    let(:range) { TimeOfDay.new(0, 0)..TimeOfDay.new(1, 0) }
    let(:weights) { described_class.weighted_x48_vector_single_range(range) }

    it 'returns expected weights' do
      expect(weights[0..1]).to eq [1.0, 1.0]
      expect(weights[2..47]).to eq Array.new(46, 0.0)
    end

    context 'with ranges on 15 min boundary' do
      let(:range) { TimeOfDay.new(8, 15)..TimeOfDay.new(10, 15) }

      it 'returns expected weights' do
        expect(weights[0..15]).to eq Array.new(16, 0.0)
        # half of the 8-8.30am period
        expect(weights[16]).to eq 0.5
        expect(weights[17..19]).to eq Array.new(3, 1.0)
        # half of the 10-10.30am period
        expect(weights[20]).to eq 0.5
        expect(weights[21..47]).to eq Array.new(27, 0.0)
      end
    end

    context 'with ranges at 10 mins and 20 mins' do
      let(:range) { TimeOfDay.new(8, 10)..TimeOfDay.new(10, 20) }

      it 'returns expected weights' do
        expect(weights[0..15]).to eq Array.new(16, 0.0)
        # two third of the 8-8.3.0am period
        expect(weights[16].round(2)).to eq 0.67
        expect(weights[17..19]).to eq Array.new(3, 1.0)
        # and two thirds of the 10-10.30am period
        expect(weights[20].round(2)).to eq 0.67
        expect(weights[21..47]).to eq Array.new(27, 0.0)
      end
    end

    context 'with ranges at 50 mins and 20 mins' do
      let(:range) { TimeOfDay.new(8, 50)..TimeOfDay.new(10, 20) }

      it 'returns expected weights' do
        expect(weights[0..16]).to eq Array.new(17, 0.0)
        # one third of the 8-8.3.0am period
        expect(weights[17].round(2)).to eq 0.33
        expect(weights[18..19]).to eq Array.new(2, 1.0)
        # and two thirds of the 10-10.30am period
        expect(weights[20].round(2)).to eq 0.67
        expect(weights[21..47]).to eq Array.new(27, 0.0)
      end
    end

    context 'with ranges at 20 mins and 50 mins' do
      let(:range) { TimeOfDay.new(8, 20)..TimeOfDay.new(10, 50) }

      it 'returns expected weights' do
        expect(weights[0..15]).to eq Array.new(16, 0.0)
        # one thirds of the 8-8.3.0am period
        expect(weights[16].round(2)).to eq 0.33
        expect(weights[17..20]).to eq Array.new(4, 1.0)
        # and two thirds of the 10-10.30am period
        expect(weights[21].round(2)).to eq 0.67
        expect(weights[22..47]).to eq Array.new(26, 0.0)
      end
    end

    context 'with morning period' do
      let(:range) { TimeOfDay.new(8, 0)..TimeOfDay.new(10, 0) }

      it 'returns expected weights' do
        expect(weights[0..15]).to eq Array.new(16, 0.0)
        expect(weights[16..19]).to eq Array.new(4, 1.0)
        expect(weights[20..47]).to eq Array.new(28, 0.0)
      end
    end

    context 'with full day' do
      let(:range) { TimeOfDay.new(0, 0)..TimeOfDay.new(24, 0) }

      it 'returns expected weights' do
        expect(described_class.weighted_x48_vector_single_range(range)).to eq(Array.new(48, 1.0))
      end
    end
  end

  describe '#weighted_x48_vector_fast_inclusive' do
    let(:range)  { TimeOfDay.new(0, 0)..TimeOfDay.new(1, 0) }
    let(:weight) { 1.0 }

    it 'returns expected weights' do
      expect(described_class.weighted_x48_vector_fast_inclusive(range,
                                                                weight)).to eq([1.0, 1.0, 1.0] + Array.new(45, 0.0))
    end

    context 'with mid day' do
      let(:range) { TimeOfDay.new(8, 0)..TimeOfDay.new(10, 0) }

      it 'returns expected weights' do
        expect(described_class.weighted_x48_vector_fast_inclusive(range,
                                                                  weight)).to eq(Array.new(16,
                                                                                           0.0) + Array.new(5,
                                                                                                            1.0) + Array.new(
                                                                                                              27, 0.0
                                                                                                            ))
      end
    end

    context 'with range ending 23:30' do
      let(:range) { TimeOfDay.new(0, 0)..TimeOfDay.new(23, 30) }

      it 'returns expected weights' do
        expect(described_class.weighted_x48_vector_fast_inclusive(range, weight)).to eq(Array.new(48, 1.0))
      end
    end

    context 'with overnight range' do
      let(:range) { TimeOfDay.new(23, 0)..TimeOfDay.new(1, 0) }

      it 'returns expected weights' do
        expect(described_class.weighted_x48_vector_fast_inclusive(range,
                                                                  weight)).to eq(Array.new(3,
                                                                                           1.0) + Array.new(43,
                                                                                                            0.0) + Array.new(
                                                                                                              2, 1.0
                                                                                                            ))
      end
    end
  end
end
