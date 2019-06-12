require 'rails_helper'


describe Equivalence do

  describe 'formatted_variables' do

    it 'pulls out the formatted equivalence value' do
      equivalence = Equivalence.new(
        data: {
          'ice_km' => {'formatted_equivalence' => '3 km', 'conversion' => 0.5},
          'trees' => {'formatted_equivalence' => '200', 'conversion' => 3},
        }
      )
      expect(equivalence.formatted_variables).to eq({
        ice_km: '3 km',
        trees: '200'
      })
    end

    it 'converts £ values to GBP' do
      equivalence = Equivalence.new(
        data: {
          'school_dinners_£' => {'formatted_equivalence' => '£2.50', 'conversion' => 0.5},
        }
      )
      expect(equivalence.formatted_variables).to eq({
        school_dinners_gbp: '£2.50'
      })
    end
  end

end
