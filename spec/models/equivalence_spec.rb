require 'rails_helper'


describe Equivalence do
  describe '#via_unit' do
    it 'returns the unit used' do
      equivalence = Equivalence.new(
        data: {
          '£' => { 'via' => '£' },
          'carnivore_dinner_£_carnivore_dinner' => { 'via' => 'this should not show' }
        }
      )
      expect(equivalence.via_unit).to eq('£')
      equivalence = Equivalence.new(
        data: {
          'kwh' => { 'via' => 'kwh' },
          'co2' => { 'via' => 'co2' },
          '£' => { 'via' => '£' },
          'carnivore_dinner_£_carnivore_dinner' => { 'via' => 'this should not show' }
        }
      )
      expect(equivalence.via_unit).to eq('kwh co2 £')
    end
  end

  describe 'formatted_variables' do
    it 'pulls out the formatted equivalence value' do
      equivalence = Equivalence.new(
        data: {
          'ice_km' => { 'formatted_equivalence' => '3 km', 'conversion' => 0.5 },
          'trees' => { 'formatted_equivalence' => '200', 'conversion' => 3 },
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
          'school_dinners_£' => { 'formatted_equivalence' => '£2.50', 'conversion' => 0.5 },
        }
      )
      expect(equivalence.formatted_variables).to eq({
        school_dinners_gbp: '£2.50'
      })
    end

    it 'fetches right version for locale' do
      equivalence = Equivalence.new(
        data: {
          'school_dinners_£' => { 'formatted_equivalence' => '£2.50', 'conversion' => 0.5 }
        },
        data_cy: {
          'school_dinners_£' => { 'formatted_equivalence' => 'WELSH', 'conversion' => 0.5 }
        }
      )
      expect(equivalence.formatted_variables(:cy)).to eq({
        school_dinners_gbp: 'WELSH'
      })
    end
  end
end
