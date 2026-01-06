require 'rails_helper'

RSpec.describe ProgrammeType, type: :model do
  describe '#tx_resources' do
    let!(:programme_type_1) { create(:programme_type, active: true, title: 'one') }
    let!(:programme_type_2) { create(:programme_type, active: false, title: 'two') }

    it 'contains active programme types' do
      expect(ProgrammeType.tx_resources).to match_array([programme_type_1])
    end
  end

  describe 'bonus score validations' do
    it 'has a valid bonus score that is equal to or greater than zero' do
      expect(ProgrammeType.new(active: true, title: 'one', bonus_score: 0)).to be_valid
      expect(ProgrammeType.new(active: true, title: 'one', bonus_score: 100)).to be_valid
      expect(ProgrammeType.new(active: true, title: 'one', bonus_score: -1)).not_to be_valid
      expect(ProgrammeType.new(active: true, title: 'one', bonus_score: nil)).not_to be_valid
    end
  end

  describe '#document_link' do
    let!(:programme_type_1) { create(:programme_type, active: true, title: 'one', document_link: 'en-doc') }

    it 'gives en version by default' do
      expect(programme_type_1.document_link).to eq('en-doc')
    end

    it 'gives en version if no cy version' do
      I18n.with_locale(:cy) do
        expect(programme_type_1.document_link).to eq('en-doc')
      end
    end

    it 'gives cy version if provided' do
      programme_type_1.update(document_link_cy: 'cy-doc')
      I18n.with_locale(:cy) do
        expect(programme_type_1.document_link).to eq('cy-doc')
      end
    end
  end

  it_behaves_like 'an assignable' do
    subject(:assignable) { create(:programme_type) }
  end
end
