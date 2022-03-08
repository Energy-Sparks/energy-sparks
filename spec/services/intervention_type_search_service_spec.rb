require 'rails_helper'

describe InterventionTypeSearchService do

  context 'search by query term' do
    it 'finds interventions by name' do
      intervention_type_1 = create(:intervention_type, title: 'foo')
      intervention_type_2 = create(:intervention_type, title: 'bar')

      expect(InterventionTypeSearchService.search('foo')).to eq([intervention_type_1])
      expect(InterventionTypeSearchService.search('bar')).to eq([intervention_type_2])
    end

    it 'only finds active intervention types' do
      intervention_type_1 = create(:intervention_type, title: 'foo baz', active: false)
      intervention_type_2 = create(:intervention_type, title: 'bar baz')

      expect(InterventionTypeSearchService.search('baz')).to eq([intervention_type_2])
    end

    it 'finds interventions by description' do
      intervention_type_1 = create(:intervention_type, description: 'foo')
      intervention_type_2 = create(:intervention_type, description: 'bar')

      expect(InterventionTypeSearchService.search('foo')).to eq([intervention_type_1])
      expect(InterventionTypeSearchService.search('bar')).to eq([intervention_type_2])
    end

    it 'must match all words' do
      intervention_type_1 = create(:intervention_type, description: 'foo baz')
      intervention_type_2 = create(:intervention_type, description: 'bar baz')

      expect(InterventionTypeSearchService.search('foo bar')).to eq([])
      expect(InterventionTypeSearchService.search('foo baz')).to eq([intervention_type_1])
      expect(InterventionTypeSearchService.search('baz')).to eq([intervention_type_1, intervention_type_2])
    end

    it 'ignores simple words' do
      intervention_type_1 = create(:intervention_type, title: 'foo and the stuff')
      intervention_type_2 = create(:intervention_type, title: 'bar and a thing')

      expect(InterventionTypeSearchService.search('and')).to eq([])
      expect(InterventionTypeSearchService.search('the')).to eq([])
      expect(InterventionTypeSearchService.search('a')).to eq([])
    end

    it 'ignores html markup' do
      intervention_type_1 = create(:intervention_type, description: '<div>foo</div>')
      intervention_type_2 = create(:intervention_type, description: '<div>bar</div>')

      expect(InterventionTypeSearchService.search('div')).to eq([])
      expect(InterventionTypeSearchService.search('<div>')).to eq([])
      expect(InterventionTypeSearchService.search('class')).to eq([])
      expect(InterventionTypeSearchService.search('foo')).to eq([intervention_type_1])
      expect(InterventionTypeSearchService.search('bar')).to eq([intervention_type_2])
    end

    it 'matches plurals' do
      intervention_type_1 = create(:intervention_type, title: 'a thing')
      intervention_type_2 = create(:intervention_type, title: 'some things')

      expect(InterventionTypeSearchService.search('thing')).to eq([intervention_type_1, intervention_type_2])
      expect(InterventionTypeSearchService.search('things')).to eq([intervention_type_1, intervention_type_2])
    end

    it 'does not match parts of words' do
      intervention_type_1 = create(:intervention_type, title: 'petrol')
      intervention_type_2 = create(:intervention_type, title: 'petroleum')

      expect(InterventionTypeSearchService.search('petrol')).to eq([intervention_type_1])
    end
  end
end
