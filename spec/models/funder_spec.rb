require 'rails_helper'

describe Funder do
  let!(:funder) { create(:funder) }

  describe '#with_schools' do
    context 'when funder has no schools or groups' do
      it 'is empty' do
        expect(Funder.with_schools).to be_empty
      end
    end

    context 'when funder has a school' do
      let!(:school) { create(:school, funder: funder)}

      it 'returns the funder' do
        expect(Funder.with_schools).to eq([funder])
      end
    end

    context 'when funder has a school group' do
      let!(:school_group) { create(:school_group, funder: funder)}
      let!(:school) { create(:school, school_group: school_group)}

      it 'returns the funder' do
        expect(Funder.with_schools).to eq([funder])
      end
    end
  end

  describe '#school_counts' do
    subject(:school_counts) { Funder.school_counts }

    context 'when funder has no schools or groups' do
      it 'returns zero count' do
        expect(school_counts.first).to have_attributes(name: funder.name, school_count: 0)
      end
    end

    context 'when funder has a school' do
      let!(:school) { create(:school, visible: true, funder: funder)}

      it 'returns the funder' do
        expect(school_counts.first).to have_attributes(name: funder.name, school_count: 1)
      end
    end

    context 'when funder has a school group' do
      let!(:school_group) { create(:school_group, funder: funder)}
      let!(:schools) { create_list(:school, 3, visible: true, school_group: school_group)}

      it 'returns the funder' do
        expect(school_counts.first).to have_attributes(name: funder.name, school_count: 3)
      end
    end

    context 'when funder has a school group and a school' do
      let!(:school_group) { create(:school_group, funder: funder)}
      let!(:school) { create(:school, visible: true, funder: funder)}
      let!(:schools) { create_list(:school, 3, visible: true, school_group: school_group)}

      it 'returns the funder' do
        expect(school_counts.first).to have_attributes(name: funder.name, school_count: 4)
      end
    end
  end
end
