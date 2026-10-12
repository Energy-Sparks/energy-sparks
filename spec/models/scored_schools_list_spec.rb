require 'rails_helper'

describe ScoredSchoolsList do
  describe '#with_points' do
    let(:school_a) { double(:school, sum_points: 30) }
    let(:school_b) { double(:school, sum_points: 20) }
    let(:school_c) { double(:school, sum_points: 0) }
    let(:school_d) { double(:school, sum_points: nil) }

    context 'when always_include is not set' do
      it 'returns just those with points' do
        expect(ScoredSchoolsList.new([school_a, school_b, school_c, school_d]).with_points).to contain_exactly(school_a, school_b)
      end
    end

    context 'when always_include is set school with 0 points' do
      it 'includes school' do
        expect(ScoredSchoolsList.new([school_a, school_b, school_c, school_d]).with_points(always_include: school_c)).to contain_exactly(school_c, school_a, school_b)
      end
    end

    context 'when always_include is set school with nil points' do
      it 'includes school' do
        expect(ScoredSchoolsList.new([school_a, school_b, school_c, school_d]).with_points(always_include: school_d)).to contain_exactly(school_d, school_a, school_b)
      end
    end
  end

  describe '#schools_with_positions' do
    context 'schools with unique points' do
      let(:school_a) { double(:school, sum_points: 30) }
      let(:school_b) { double(:school, sum_points: 20) }
      let(:school_c) { double(:school, sum_points: 5) }

      it 'orders the schools based on their index' do
        expect(ScoredSchoolsList.new([school_a, school_b, school_c]).schools_with_positions).to eq(
          {
            1 => [school_a],
            2 => [school_b],
            3 => [school_c]
          }
        )
      end
    end

    context 'schools with the same points' do
      let(:school_a) { double(:school, sum_points: 30) }
      let(:school_b) { double(:school, sum_points: 20) }
      let(:school_c) { double(:school, sum_points: 20) }
      let(:school_d) { double(:school, sum_points: 5) }
      let(:school_e) { double(:school, sum_points: 1) }
      let(:school_f) { double(:school, sum_points: 1) }

      it 'orders the schools based on their index' do
        expect(ScoredSchoolsList.new([school_a, school_b, school_c, school_d, school_e, school_f]).schools_with_positions).to eq(
          {
            1 => [school_a],
            2 => [school_b, school_c],
            3 => [school_d],
            4 => [school_e, school_f]
          }
        )
      end
    end
  end

  describe '#top_by_recent_points' do
    let(:school_a) { double(:school, recent_points: 4) }
    let(:school_b) { double(:school, recent_points: 10) }
    let(:school_c) { double(:school, recent_points: nil) }
    let(:school_d) { double(:school, recent_points: 0) }

    it 'returns the school with the most recent points' do
      list = ScoredSchoolsList.new([school_a, school_b, school_c, school_d])

      expect(list.top_by_recent_points).to eq(school_b)
    end

    it 'returns nil when no school has recent points' do
      list = ScoredSchoolsList.new([school_c, school_d])

      expect(list.top_by_recent_points).to be_nil
    end
  end
end
