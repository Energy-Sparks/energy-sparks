
require 'rails_helper'

describe ScoredSchoolsList do

  describe '#schools_with_positions' do

    context 'schools with unique points' do

      let(:school_a){ double(:school, sum_points: 30)}
      let(:school_b){ double(:school, sum_points: 20)}
      let(:school_c){ double(:school, sum_points: 5)}

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

      let(:school_a){ double(:school, sum_points: 30)}
      let(:school_b){ double(:school, sum_points: 20)}
      let(:school_c){ double(:school, sum_points: 20)}
      let(:school_d){ double(:school, sum_points: 5)}
      let(:school_e){ double(:school, sum_points: 1)}
      let(:school_f){ double(:school, sum_points: 1)}

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

end
