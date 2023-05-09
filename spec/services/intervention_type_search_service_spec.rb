require 'rails_helper'

describe InterventionTypeSearchService do

  context 'search by query term' do
    before { I18n.locale = 'en' }

    it 'finds interventions by name' do
      intervention_type_1 = create(:intervention_type, name: 'foo')
      intervention_type_2 = create(:intervention_type, name: 'bar')

      expect(InterventionTypeSearchService.search('foo', 'en')).to eq([intervention_type_1])
      expect(InterventionTypeSearchService.search('bar', 'en')).to eq([intervention_type_2])
    end

    it 'only finds active intervention types' do
      intervention_type_1 = create(:intervention_type, name: 'foo baz', active: false)
      intervention_type_2 = create(:intervention_type, name: 'bar baz')

      expect(InterventionTypeSearchService.search('baz', 'en')).to eq([intervention_type_2])
    end

    it 'finds interventions by description' do
      intervention_type_1 = create(:intervention_type, description: 'foo')
      intervention_type_2 = create(:intervention_type, description: 'bar')

      expect(InterventionTypeSearchService.search('foo', 'en')).to eq([intervention_type_1])
      expect(InterventionTypeSearchService.search('bar', 'en')).to eq([intervention_type_2])
    end

    it 'must match all words' do
      intervention_type_1 = create(:intervention_type, description: 'foo baz')
      intervention_type_2 = create(:intervention_type, description: 'bar baz')

      expect(InterventionTypeSearchService.search('foo bar', 'en')).to eq([])
      expect(InterventionTypeSearchService.search('foo baz', 'en')).to eq([intervention_type_1])
      expect(InterventionTypeSearchService.search('baz', 'en')).to match_array([intervention_type_1, intervention_type_2])
    end

    it 'ignores simple words' do
      intervention_type_1 = create(:intervention_type, name: 'foo and the stuff')
      intervention_type_2 = create(:intervention_type, name: 'bar and a thing')

      expect(InterventionTypeSearchService.search('and', 'en')).to eq([])
      expect(InterventionTypeSearchService.search('the', 'en')).to eq([])
      expect(InterventionTypeSearchService.search('a', 'en')).to eq([])
    end

    it 'ignores html markup' do
      intervention_type_1 = create(:intervention_type, description: '<div>foo</div>')
      intervention_type_2 = create(:intervention_type, description: '<div>bar</div>')

      expect(InterventionTypeSearchService.search('div', 'en')).to eq([])
      expect(InterventionTypeSearchService.search('<div>', 'en')).to eq([])
      expect(InterventionTypeSearchService.search('class', 'en')).to eq([])
      expect(InterventionTypeSearchService.search('foo', 'en')).to eq([intervention_type_1])
      expect(InterventionTypeSearchService.search('bar', 'en')).to eq([intervention_type_2])
    end

    it 'matches plurals' do
      intervention_type_1 = create(:intervention_type, name: 'a thing')
      intervention_type_2 = create(:intervention_type, name: 'some things')

      expect(InterventionTypeSearchService.search('thing', 'en')).to include(*[intervention_type_1, intervention_type_2])
      expect(InterventionTypeSearchService.search('things', 'en')).to include(*[intervention_type_1, intervention_type_2])
    end

    it 'does not match parts of words' do
      intervention_type_1 = create(:intervention_type, name: 'petrol')
      intervention_type_2 = create(:intervention_type, name: 'petroleum')

      expect(InterventionTypeSearchService.search('petrol', 'en')).to eq([intervention_type_1])
    end
  end
end
