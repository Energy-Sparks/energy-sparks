require 'rails_helper'

describe 'InterventionType' do

  subject { create :intervention_type }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid with invalid attributes' do
    type = build :intervention_type, score: -1
    expect( type ).to_not be_valid
    expect( type.errors[:score] ).to include('must be greater than or equal to 0')
  end

  context 'when translations are being applied' do
    let(:old_name) { 'old-name' }
    let(:new_name) { 'new-name' }

    it 'updates original name so search still works' do
      intervention_type = create(:intervention_type, name: old_name)
      expect(InterventionType.search(new_name)).to eq([])

      intervention_type.update(name: new_name)

      expect(intervention_type.attributes['name']).to eq(new_name)
      expect(InterventionType.search(new_name)).to eq([intervention_type])
    end
  end

  context 'search by query term' do
    it 'finds interventions by name' do
      intervention_type_1 = create(:intervention_type, name: 'foo')
      intervention_type_2 = create(:intervention_type, name: 'bar')

      expect(InterventionType.search('foo')).to eq([intervention_type_1])
      expect(InterventionType.search('bar')).to eq([intervention_type_2])
    end

    it 'applies search variants' do
      intervention_type_1 = create(:intervention_type, name: 'time')
      intervention_type_2 = create(:intervention_type, name: 'timing')

      expect(InterventionType.search('timing')).to eq([intervention_type_1, intervention_type_2])
    end
  end
end
